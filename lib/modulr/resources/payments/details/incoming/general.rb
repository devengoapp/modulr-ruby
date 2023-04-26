# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      module Details
        module Incoming
          class General < Base
            attr_reader :payer, :payee, :destination

            map :created, :created_at
            map :posted, :posted_at
            map :retryCount, :retry_count
            map :reprocess
            map :sourceService, :source_service
            map :providerCode, :provider_code
            map :ledgerBankCode, :ledger_bank_code
            map :clearingRequired, :clearing_required
            map :requestReference, :request_reference
            map :accountNumber, :account_number
            map :type
            map :amount
            map :currency
            map :description
            map :originalReference, :original_reference
            map :schemeId, :scheme_id
            map :schemeType, :scheme_type
            map :details, :raw_details

            def initialize(raw_response, attributes = {})
              super(raw_response, attributes)
              @payer = Counterparty.new(nil, attributes[:payer])
              @payee = Counterparty.new(nil, attributes[:payee])
              @destination = parse_destination(attributes)
            end

            private def parse_destination(attributes)
              destination_params = attributes[:payee][:identifier].merge!(name: attributes[:payee][:name])

              Destination.new(nil, destination_params)
            end
          end
        end
      end
    end
  end
end
