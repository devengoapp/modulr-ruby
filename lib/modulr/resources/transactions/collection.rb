# frozen_string_literal: true

module Modulr
  module Resources
    module Transactions
      class Transactions < BaseCollection
        def initialize(response)
          super(response.env[:raw_body], Transaction, response.body[:content])
        end
      end
    end
  end
end
