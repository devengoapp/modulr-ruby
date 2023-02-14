# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        attr_reader :details

        map :id, [:id, :payment_reference_id]
        map :status
        map :reference
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :approvalStatus, :approval_status

        def initialize(response, attributes = {})
          super(response, attributes)
          @details = Details.new(response, attributes[:details])
        end
      end
    end
  end
end
