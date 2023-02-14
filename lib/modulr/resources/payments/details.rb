# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Details < Base
        attr_reader :destination

        map :sourceAccountId, :source_account_id
        map :currency
        map :amount
        map :reference

        def initialize(response, attributes = {})
          super(response, attributes)
          @destination = Destination.new(response, attributes[:destination])
        end
      end
    end
  end
end
