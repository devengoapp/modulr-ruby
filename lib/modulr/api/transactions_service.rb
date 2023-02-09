# frozen_string_literal: true

module Modulr
  module API
    class TransactionsService < Service
      def list(account_id:, **opts)
        response = client.get("/accounts/#{account_id}/transactions", opts)
        Resources::Transactions::Transactions.new(response, response.body[:content])
      end
    end
  end
end
