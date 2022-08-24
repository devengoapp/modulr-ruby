# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transactions < Collection
        def initialize(response, attributes_collection)
          super(response, Transaction, attributes_collection)
        end
      end
    end
  end
end
