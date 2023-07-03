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

        private def parse_attributes(attributes) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          details = attributes[:details]

          case type
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
          when "PO_SECT"
            outgoing_detail(details)
            sepa_regular
          when "PO_SEPA_INST"
            outgoing_detail(details)
            sepa_instant
          when "PO_FAST"
            outgoing_detail(details)
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
