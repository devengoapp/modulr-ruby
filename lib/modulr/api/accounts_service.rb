# frozen_string_literal: true

module Modulr
  module API
    class AccountsService < Service
      def find(id:)
        response = client.get("/accounts/#{id}")
        Resources::Accounts::Account.new(response.env[:raw_body], response.body)
      end

      def create(customer_id:, currency:, product_code:, **opts)
        payload = {
          currency: currency,
          productCode: product_code,
        }
        payload[:externalReference] = opts[:external_reference] if opts[:external_reference]

        response = client.post("/customers/#{customer_id}/accounts", payload)
        Resources::Accounts::Account.new(response.env[:raw_body], response.body)
      end

      def close(account_id:)
        client.post("/accounts/#{account_id}/close")

        nil
      end
    end
  end
end
