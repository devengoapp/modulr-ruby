# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Account < Base
        attr_reader :identifiers

        STATUS = {
          active: "ACTIVE",
          blocked: "BLOCKED",
          closed: "CLOSED",
          client_blocked: "CLIENT_BLOCKED",
        }.freeze
        map :id, :id
        map :balance, :balance
        map :availableBalance, :available_balance
        map :currency, :currency
        map :status, :status
        map :customerId, :customer_id
        map :customerName, :customer_name
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :directDebit, :direct_debit

        def initialize(response, attributes = {})
          super(response, attributes)
          @identifiers = Accounts::Identifiers.new(response, attributes[:identifiers])
        end
      end
    end
  end
end
