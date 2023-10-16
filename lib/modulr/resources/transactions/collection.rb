# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transactions < BaseCollection
        def initialize(response)
          super(response, Transaction, response.body[:content])
        end
      end
    end
  end
end
