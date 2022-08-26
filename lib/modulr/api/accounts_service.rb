# frozen_string_literal: true

module Modulr
  module API
    class AccountsService < Service
      def create(customer_id:, currency:, product_code:, options: {})
        data = {
          currency: currency,
          productCode: product_code,
        }
        data[:externalReference] = options[:external_reference] if options[:external_reference]
        response = client.post("/customers/#{customer_id}/accounts", data, options)
        Resources::Accounts::Account.new(response, response.body)
      end

      def info(account_id:)
        response = client.get("/accounts/#{account_id}")
        Resources::Accounts::Account.new(response, response.body)
      end
    end
  end
end
