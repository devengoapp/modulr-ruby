# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transaction < Base
        map :id, :id
        map :amount, :amount
        map :currency, :currency
        map :description, :description
        map :transactionDate, :created_at
        map :postedDate, :date
        map :credit, :credit
        map :type, :type
        map :sourceId, :source_id
        map :sourceExternalReference, :external_reference
        map :additionalInfo, :additional_info
        map :balance, :balance
        map :available_balance, :available_balance

        def initialize(response, attrs)
          super
          @balance = attrs[:account][:balance]
          @available_balance = attrs[:account][:availableBalance]
        end
      end
    end
  end
end
