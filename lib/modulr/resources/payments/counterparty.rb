# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Counterparty < Base
        attr_reader :identifier

        map :name
        map :address

        def initialize(attributes = {})
          super(attributes)
          @identifier = Accounts::Identifier.new(attributes[:identifier])
        end
      end
    end
  end
end
