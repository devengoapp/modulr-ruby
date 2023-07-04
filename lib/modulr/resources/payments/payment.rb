# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        attr_reader :details, :end_to_end_id, :network, :scheme

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
          @end_to_end_id = if incoming_sepa?(attributes)
                             sepa_end_to_end_id(attributes)
                           elsif incoming_faster_payments?(attributes)
                             faster_payments_end_to_end_id(attributes)
                           end
        end

        private def incoming_sepa?(attributes)
          %w[PI_SECT PI_SEPA_INST].include?(attributes[:details]&.dig(:type))
        end

        private def incoming_faster_payments?(attributes)
          attributes[:details]&.dig(:type) == "PI_FAST"
        end

        private def sepa_end_to_end_id(attributes)
          doc = attributes[:details].dig(:details, :payload, :docs, :doc)
          return unless doc

          doc_type = doc.dig(:header, :type)
          key = doc_type.downcase.to_sym

          case doc_type
          when "IFCCTRNS" # SEPA instant
            doc.dig(key, :document, :fitoFICstmrCdtTrf, :cdtTrfTxInf, :pmtId, :endToEndId)
          when "FFCCTRNS" # SEPA regular
            doc.dig(key, :document, :fitoFICstmrCdtTrf, :cdtTrfTxInf).first&.dig(:pmtId, :endToEndId)
          end
        end

        private def faster_payments_end_to_end_id(attributes)
          attributes[:details].dig(:details, :fpsTransaction, :paymentInfo, :endToEndId)
        end

        private def parse_attributes(attributes)
          parse_details(attributes)
          parse_scheme if type
        end

        private def parse_details(attributes)
          details = attributes[:details]
          detail_type = details&.dig(:type) || details&.dig(:destinationType)

          case detail_type
          when "PI_SECT", "PI_SEPA_INST", "PI_FAST", "PI_REV"
            incoming_detail(details)
          when "ACCOUNT"
            incoming_internal_details(details)
          else
            outgoing_detail(details)
          end
        end

        private def parse_scheme
          case type
          when "PI_SECT", "PO_SECT"
            sepa_regular
          when "PI_SEPA_INST", "PO_SEPA_INST"
            sepa_instant
          when "PI_FAST", "PO_FAST"
            faster_payments
          when "ACCOUNT", "INT_INTERC"
            internal
          else
            raise "Unable to find network and scheme for payment with ID: #{id} and Type: #{type}"
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
