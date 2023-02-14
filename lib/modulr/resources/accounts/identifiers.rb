# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifiers < BaseCollection
        def initialize(response, attributes_collection)
          super(response, Identifier, attributes_collection)
        end
      end
    end
  end
end
