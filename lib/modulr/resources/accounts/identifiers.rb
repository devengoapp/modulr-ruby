# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifiers < BaseCollection
        def initialize(response)
          super(nil, Identifier, response.body[:identifiers])
        end
      end
    end
  end
end
