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

        def initialize(raw_response, attributes = {})
          super(raw_response, attributes)
          @details = parse_details(attributes[:details])
        end

        private def parse_details(details)
          case details[:type]
          when "PI_SECT", "PI_SEPA_INST", "PI_FAST", "PI_REV"
            Details::Incoming::General.new(nil, details)
          when "PO_SECT", "PO_SEPA_INST", "PO_FAST", "PO_REV"
            Details::Outgoing::General.new(nil, details)
          when nil
            Details::Internal.new(nil, details)
          end
        end
      end
    end
  end
end
