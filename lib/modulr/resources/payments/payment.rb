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

        def initialize(attributes = {})
          super(attributes)
          @details = parse_details(attributes[:details])
        end

        private def parse_details(details)
          case details[:type]
          when "PI_SEPA_INST", "PI_FAST"
            Details::Incoming::General.new(details)
          else
            Details::Outgoing::General.new(details)
          end
        end
      end
    end
  end
end
