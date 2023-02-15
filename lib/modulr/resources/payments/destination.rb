# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Destination < Base
        map :type
        map :iban
        map :name
      end
    end
  end
end
