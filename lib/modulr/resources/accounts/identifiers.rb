# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifiers < BaseCollection
        def initialize(attributes_collection)
          super(nil, Identifier, attributes_collection)
        end
      end
    end
  end
end
