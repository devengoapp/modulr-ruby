# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Config < Base
        map :retry
        map :secret
        map :hmacAlgorithm, :hmac_algorithm
      end
    end
  end
end
