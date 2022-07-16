# frozen_string_literal: true

module Modulr
  module API
    class AccountsService < Service
      def info(account_id:)
        response = client.get("/accounts/#{account_id}")
        puts response.body
        Resources::Accounts::Account.new(response, response.body)
      end
    end
  end
end
