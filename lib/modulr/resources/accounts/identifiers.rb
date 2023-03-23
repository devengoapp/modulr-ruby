# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifiers < BaseCollection
        def initialize(raw_response, attributes_collection)
          super(raw_response, Identifier, attributes_collection)
        end
      end
    end
  end
end
