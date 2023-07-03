# frozen_string_literal: true

module Modulr
  module API
    class PaymentsService < Service
      def find(id:, **opts)
        response = client.get("/payments", { id: id })
        payment_attributes = if include_transaction?(opts)
                               payment_attributes_with_type(id, response.body[:content]&.first)
                             else
                               response.body[:content]&.first
                             end

        Resources::Payments::Payment.new(response.env[:raw_body], payment_attributes)
      end

      def list(**opts) # rubocop:disable Metrics/AbcSize
        return find(id: opts[:id]) if opts[:id]

        response = client.get("/payments", build_query_params(opts))

        if include_transaction?(opts)
          response.body[:content].each do |payment_attributes|
            payment_attributes_with_type(payment_attributes[:id], payment_attributes)
          end
        end

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

      private def include_transaction?(opts)
        return true if opts[:include_transaction].nil?

        opts[:include_transaction]
      end

      private def payment_attributes_with_type(id, attrs)
        raise NotFoundError, "Payment #{id} not found" unless attrs

        @details = attrs[:details]
        type = if outgoing && !internal
                 fetch_transaction_type
               elsif incoming
                 @details[:type]
               elsif internal
                 @details[:destinationType]
               end

        attrs[:type] = type
        attrs
      end

      private def fetch_transaction_type
        client.transactions.list(
          account_id: @details[:sourceAccountId],
          source_id: @details[:id]
        )&.first&.type
      end

      private def incoming
        @details[:sourceAccountId].nil?
      end

      private def internal
        @details[:sourceAccountId] && @details[:destinationId]
      end

      private def outgoing
        !@details[:sourceAccountId].nil? && @details[:destinationId].nil?
      end
    end
  end
end
