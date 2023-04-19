# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      module Details
        class Internal < Base
          attr_reader :destination

          map :sourceAccountId, :source_account_id
          map :externalReference, :external_reference
          map :currency
          map :amount
          map :description
          map :reference

          def initialize(raw_response, attributes = {})
            super(raw_response, attributes)
            @destination = Destination.new(nil, attributes[:destination])
          end
        end
      end
    end
  end
end
