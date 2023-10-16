# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Destination < Base
        attr_reader :identifier

        map :type
        map :name

        def initialize(response, attributes = {})
          super(response, attributes)

          @identifier = Accounts::Identifier.new(nil, attributes)
        end
      end
    end
  end
end
