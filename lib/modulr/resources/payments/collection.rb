# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Collection < BaseCollection
        def initialize(response)
          super(response.env[:raw_body], Payment, response.body[:content])
        end
      end
    end
  end
end
