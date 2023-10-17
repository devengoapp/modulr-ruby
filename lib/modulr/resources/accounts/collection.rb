# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Collection < BaseCollection
        def initialize(response, attributes_collection)
          super(response, Account, attributes_collection)
        end
      end
    end
  end
end
