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
        map :credit
        map :type
        map :transactionDate, :created_at
        map :postedDate, :posted_date
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
