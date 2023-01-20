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



#{:id=>"C120PVKN", :name=>"Devengo Sandbox", :type=>"INDIVIDUAL", :status=>"ACTIVE", :verificationStatus=>"VERIFIED", :expectedMonthlySpend=>1,
#
#  :associates=>[
#
#    {:id=>"S120ZCGU", :firstName=>"Minnie", :middleName=>"", :lastName=>"Mouse", :email=>"minniemouse@yahoo.co.uk", :phone=>"+(44)7321470579", :applicant=>true, :type=>"INDIVIDUAL", :dateOfBirth=>"1990-09-09", :verificationStatus=>"VERIFIED", :homeAddress=>{:id=>147802512, :addressLine1=>"130 old man street", :addressLine2=>"", :postTown=>"London", :postCode=>"n5 6Bu", :country=>"GB"}}
#
#    ],
#    :industryCode=>"", :tcsVersion=>1, :externalReference=>"", :createdDate=>"2021-12-23T11:05:19.051+0000", :holdPaymentsForFunds=>false, :cardConstraintsBid=>"", :needAddressVerification=>false, :accessGroupsVisible=>false, :legalEntity=>"GB"}
#
