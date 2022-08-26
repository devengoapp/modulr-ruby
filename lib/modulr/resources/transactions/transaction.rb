# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transaction < Base
        attr_reader :balance, :available_balance

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

        def initialize(response, attributes = {})
          super(response, attributes)

          @balance = attributes[:account][:balance]
          @available_balance = attributes[:account][:availableBalance]
        end
      end
    end
  end
end
