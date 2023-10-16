# frozen_string_literal: true

module Modulr
  module Resources
    module Customers
      class Customer < Base
        map :id
        map :name
        map :type
        map :status
        map :verificationStatus, :verification_status
        map :companyRegNumber, :taxid
        map :expectedMonthlySpend, :expected_monthly_spend
        map :partnerId, :partner_id
        map :industryCode, :industry_code
        map :tcsVersion, :tcs_version
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :holdPaymentsForFunds, :hold_payments_for_funds
        map :cardConstraintsBid, :card_constraints_bid
        map :needAddressVerification, :need_address_verification
        map :accessGroupsVisible, :access_groups_visible
        map :legalEntity, :legal_entity

        def initialize(response, attributes)
          super(response, attributes)
        end
      end
    end
  end
end
