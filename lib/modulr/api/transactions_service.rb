# frozen_string_literal: true

module Modulr
  module API
    class TransactionsService < Service
      def history(account_id:)
        response = client.get("/accounts/#{account_id}/transactions")
        Resources::Transactions::Transactions.new(response, response.body[:content])
      end
    end
  end
end
