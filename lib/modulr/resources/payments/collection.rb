# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Collection < BaseCollection
        def initialize(attributes_collection)
          super(Payment, attributes_collection)
        end
      end
    end
  end
end
