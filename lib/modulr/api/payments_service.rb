# frozen_string_literal: true

module Modulr
  module API
    class PaymentsService < Service
      def find(id:)
        response = client.get("/payments", { id: id })
        payment_attributes = response.body[:content]&.first
        raise ClientError, "Payment #{id} not found" unless payment_attributes

        Resources::Payments::Payment.new(response, payment_attributes)
      end

      def list(**opts)
        return find(id: opts[:id]) if opts[:id]

        response = client.get("/payments", build_query_params(opts))
        Resources::Payments::Collection.new(response)
      end

      def create(account_id:, destination:, reference:, currency:, amount:, **opts) # rubocop:disable Metrics/ParameterLists
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
        Resources::Payments::Payment.new(response, response.body, { network_scheme: false })
      end

      private def build_query_params(opts) # rubocop:disable Metrics/AbcSize
        same_name_params = [:type, :status, :size, :page]
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
    end
  end
end
