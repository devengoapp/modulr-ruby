# frozen_string_literal: true

module Modulr
  module API
    class AccountsService < Service
      def create(
        customer_id:,
        currency: "EUR",
        product_code: "O1200001",
        options: {}
      )
        data = {
          currency: currency,
          productCode: product_code,
        }
        data[:externalReference] = options[:external_reference] if options[:external_reference]
        response = client.post("/customers/#{customer_id}/accounts", data, options)
        Resources::Accounts::Account.new(response, response.body)
      end

      def close(account_id:)
        client.post("/accounts/#{account_id}/close")
      end

      def info(account_id:)
        response = client.get("/accounts/#{account_id}")
        Resources::Accounts::Account.new(response, response.body)
      end
    end
  end
end
