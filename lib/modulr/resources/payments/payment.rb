# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        attr_reader :details, :end_to_end_id

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
