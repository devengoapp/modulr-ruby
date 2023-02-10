# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payments < Collection
        def initialize(response, attributes_collection)
          super(response, Payment, attributes_collection)
        end
      end
    end
  end
end
