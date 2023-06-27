# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        attr_reader :details, :network, :scheme

        map :id, [:id, :payment_reference_id]
        map :status
        map :reference
        map :externalReference, :external_reference
        map :createdDate, :created_at
        map :approvalStatus, :approval_status
        map :message, :message
        map :type

        def initialize(raw_response, attributes = {})
          super(raw_response, attributes)
          parse_attributes(attributes)
        end

        private def parse_attributes(attributes)
          details = attributes[:details]

          case details&.dig(:type) || details&.dig(:destinationType)
          when "PI_SECT"
            incoming_detail(details)
            sepa_regular
          when "PI_SEPA_INST"
            incoming_detail(details)
            sepa_instant
          when "PI_FAST"
            incoming_detail(details)
            faster_payments
          when "PI_REV"
            incoming_detail(details)
            @network = nil
            @scheme = nil
          when "ACCOUNT"
            incoming_internal_details(details)
            internal
          else
            outgoing_payment_details(details)
          end
        end

        private def outgoing_payment_details(details)
          outgoing_detail(details)

          case type
          when "PO_SECT"
            sepa_regular
          when "PO_SEPA_INST"
            sepa_instant
          when "PO_FAST"
            faster_payments
          when "INT_INTERC"
            internal
          else
            @network = nil
            @scheme = nil
          end
        end

        private def sepa_regular
          @network = "SEPA"
          @scheme = "SEPA Credit Transfers"
        end

        private def sepa_instant
          @network = "SEPA"
          @scheme = "SEPA Instant Credit Transfers"
        end

        private def faster_payments
          @network = "FPS"
          @scheme = "Faster Payments"
        end

        private def internal
          @network = "INTERNAL"
          @scheme = "INTERNAL"
        end

        private def incoming_detail(details)
          @details = Details::Incoming::General.new(nil, details)
        end

        private def outgoing_detail(details)
          @details = Details::Outgoing::General.new(nil, details)
        end

        private def incoming_internal_details(details)
          @details = Details::Incoming::Internal.new(nil, details)
        end
      end
    end
  end
end