# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      module Details
        module Outgoing
          class General < Base
            attr_reader :destination

            map :sourceAccountId, :source_account_id
            map :currency
            map :amount
            map :reference

            def initialize(attributes = {})
              super(attributes)
              @destination = Destination.new(attributes[:destination])
            end
          end
        end
      end
    end
  end
end
