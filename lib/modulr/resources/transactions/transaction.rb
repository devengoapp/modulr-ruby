# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transaction < Base
        attr_reader :balance, :available_balance

        map :id
        map :amount
        map :currency
        map :description
        map :transactionDate, :created_at
        map :postedDate, :final_at
        map :credit
        map :type
        map :sourceId, :source_id
        map :sourceExternalReference, :external_reference
        map :additionalInfo, :additional_info

        def initialize(attributes = {})
          super(attributes)

          @balance = attributes[:account][:balance]
          @available_balance = attributes[:account][:availableBalance]
        end
      end
    end
  end
end
