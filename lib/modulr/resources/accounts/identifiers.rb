# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifiers < Collection
        def initialize(response, attributes_collection)
          super(response, Identifier, attributes_collection)
        end
      end
    end
  end
end
