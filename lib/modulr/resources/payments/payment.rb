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

        def initialize(raw_response, attributes = {}, opts = { network_scheme: true })
          super(raw_response, attributes)
          @attributes = attributes
          @opts = opts
          parse_attributes
          @end_to_end_id = if incoming_sepa?
                             sepa_end_to_end_id
                           elsif incoming_faster_payments?
                             faster_payments_end_to_end_id
                           end
        end

        private def incoming_sepa?
          %w[PI_SECT PI_SEPA_INST].include?(@attributes[:details]&.dig(:type))
        end

        private def incoming_faster_payments?
          @attributes[:details]&.dig(:type) == "PI_FAST"
        end

        private def sepa_end_to_end_id
          doc = @attributes[:details].dig(:details, :payload, :docs, :doc)
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

        private def faster_payments_end_to_end_id
          @attr_details.dig(:details, :fpsTransaction, :paymentInfo, :endToEndId)
        end

        private def parse_attributes
          parse_details
          parse_scheme if @opts[:network_scheme]
        end

        private def parse_details
          @attr_details = @attributes[:details]
          detail_type = @attr_details&.dig(:type) || @attr_details&.dig(:destinationType)

          case detail_type
          when "PI_SECT", "PI_SEPA_INST", "PI_FAST", "PI_REV"
            incoming_detail
          when "ACCOUNT"
            incoming_internal_details
          else
            outgoing_detail
          end
        end

        private def payment_type
          if incoming?
            @attr_details[:type]
          elsif internal?
            @attr_details[:destinationType]
          else
            outgoing_type
          end
        end

        private def parse_scheme
          case payment_type
          when "PI_SECT", "PO_SECT"
            sepa_regular
          when "PI_SEPA_INST", "PO_SEPA_INST"
            sepa_instant
          when "PI_FAST", "PO_FAST"
            faster_payments
          when "ACCOUNT"
            internal
          else
            raise "Unable to find network and scheme for payment with ID: #{id} and Type: #{type}"
          end
        end

        private def outgoing_type
          return "PO_FAST" if @attributes.dig(:schemeInfo, :id)&.include?("MODULO")

          case @attributes.dig(:schemeInfo, :name)
          when "SEPA_INSTANT"
            "PO_SEPA_INST"
          when "SEPA_CREDIT_TRANSFER"
            "PO_SECT"
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

        private def incoming_detail
          @details = Details::Incoming::General.new(nil, @attr_details)
        end

        private def outgoing_detail
          @details = Details::Outgoing::General.new(nil, @attr_details)
        end

        private def incoming_internal_details
          @details = Details::Incoming::Internal.new(nil, @attr_details)
        end

        private def incoming?
          !@attr_details.key?(:sourceAccountId)
        end

        private def internal?
          @attr_details[:sourceAccountId] && @attr_details[:destinationId]
        end
      end
    end
  end
end
