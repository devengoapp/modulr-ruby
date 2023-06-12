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
        map :message, :message

        def initialize(raw_response, attributes = {})
          super(raw_response, attributes)
          @details = parse_details(attributes)
        end

        private def parse_details(attributes)
          details = attributes[:details]

          case details&.dig(:type) || details&.dig(:destinationType)
          when "PI_SECT", "PI_SEPA_INST", "PI_FAST", "PI_REV"
            Details::Incoming::General.new(nil, details)
          when "ACCOUNT"
            Details::Incoming::Internal.new(nil, details)
          else
            Details::Outgoing::General.new(nil, details)
          end
        end
      end
    end
  end
end
