# frozen_string_literal: true

module Modulr
  module API
    class PaymentsService < Service
      def find(id:) # rubocop:disable Metrics/AbcSize
        response = client.get("/payments", { id: id })
        @payment_attributes = response.body[:content]&.first
        raise NotFoundError, "Payment #{id} not found" unless @payment_attributes

        type = if outgoing && !internal
                 fetch_transaction_type
               elsif incoming
                 @payment_attributes[:details][:type]
               elsif internal
                 @payment_attributes[:details][:destinationType]
               end

        @payment_attributes = @payment_attributes.merge(type: type)

        Resources::Payments::Payment.new(response.env[:raw_body], @payment_attributes)
      end

      def list(**opts)
        return find(id: opts[:id]) if opts[:id]

        response = client.get("/payments", build_query_params(opts))
        Resources::Payments::Collection.new(response.env[:raw_body], response.body[:content])
      end

      # rubocop:disable Metrics/ParameterLists
      def create(account_id:, destination:, reference:, currency:, amount:, **opts)
        payload = {
          sourceAccountId: account_id,
          destination: destination,
          reference: reference,
          currency: currency,
          amount: amount,
        }

        payload[:externalReference] = opts[:external_reference] if opts[:external_reference]
        payload[:endToEndReference] = opts[:e2e_reference] if opts[:e2e_reference]

        response = client.post("/payments", payload)
        Resources::Payments::Payment.new(response.env[:raw_body], response.body)
      end
      # rubocop:enable Metrics/ParameterLists

      # rubocop:disable Metrics/AbcSize
      private def build_query_params(opts)
        same_name_params = [:type, :status]
        date_params = { to: :toCreatedDate, from: :fromCreatedDate, updated_since: :modifiedSince }
        mapped_params = {
          external_reference: :externalReference,
          has_external_reference: :hasExternalReference,
          account_id: :sourceAccountId,
        }
        {}.tap do |params|
          same_name_params.each { |param| params[param] = opts[param] if opts[param] }
          date_params.each { |original, mapped| params[mapped] = format_datetime(opts[original]) if opts[original] }
          mapped_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
        end
      end
      # rubocop:enable Metrics/AbcSize

      private def fetch_transaction_type
        client.transactions.list(account_id: @payment_attributes[:details][:sourceAccountId],
                                 source_id: @payment_attributes[:id]).first.type
      end

      private def incoming
        @payment_attributes[:details][:sourceAccountId].nil?
      end

      private def internal
        @payment_attributes[:details][:sourceAccountId] && @payment_attributes[:details][:destinationId]
      end

      private def outgoing
        !@payment_attributes[:details][:sourceAccountId].nil? && @payment_attributes[:details][:destinationId].nil?
      end
    end
  end
end
