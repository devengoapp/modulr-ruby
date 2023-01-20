# frozen_string_literal: true

module Modulr
  module Resources
    module Customers
      class Customer < Base
        attr_accessor :id,
                      :name,
                      :type,
                      :status,
                      :verificationStatus,
                      :expectedMonthlySpend,
                      :industryCode,
                      :tcsVersion,
                      :externalReference,
                      :createdDate,
                      :holdPaymentsForFunds,
                      :cardConstraintsBid,
                      :needAddressVerification,
                      :accessGroupsVisible,
                      :legalEntity

        alias created_at createdDate
      end
    end
  end
end
