# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        map :id, [:id, :payment_reference_id]
        map :status
        map :reference
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :approvalStatus, :approval_status
      end
    end
  end
end
