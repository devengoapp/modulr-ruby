# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Counterparty < Base
        attr_reader :identifier

        map :name
        map :address

        def initialize(raw_response, attributes = {})
          super(raw_response, attributes)
          @identifier = Accounts::Identifier.new(nil, attributes[:identifier])
        end
      end
    end
  end
end
