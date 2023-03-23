# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transactions < BaseCollection
        def initialize(raw_response, attributes_collection)
          super(raw_response, Transaction, attributes_collection)
        end
      end
    end
  end
end
