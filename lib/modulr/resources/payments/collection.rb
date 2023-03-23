# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Collection < BaseCollection
        def initialize(raw_response, attributes_collection)
          super(raw_response, Payment, attributes_collection)
        end
      end
    end
  end
end
