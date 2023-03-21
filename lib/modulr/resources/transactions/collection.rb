# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transactions < BaseCollection
        def initialize(attributes_collection)
          super(Transaction, attributes_collection)
        end
      end
    end
  end
end
