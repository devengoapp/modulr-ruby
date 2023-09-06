# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Account < Base
        attr_reader :identifiers, :requested_at

        STATUS = {
          active: "ACTIVE",
          blocked: "BLOCKED",
          closed: "CLOSED",
          client_blocked: "CLIENT_BLOCKED",
        }.freeze
        map :id
        map :balance
        map :currency
        map :status
        map :availableBalance, :available_balance
        map :customerId, :customer_id
        map :customerName, :customer_name
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :directDebit, :direct_debit

        def initialize(raw_response, attributes = {}, opts = { requested_at: nil })
          super(raw_response, attributes)
          @requested_at = opts[:requested_at]
          @identifiers = Accounts::Identifiers.new(nil, attributes[:identifiers])
        end
      end
    end
  end
end
