# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Notification < Base
        attr_reader :config

        map :id
        map :type
        map :channel
        map :status
        map :destinations

        def initialize(response, attributes = {})
          raw_response = response.nil? ? nil : response.env[:raw_body]

          super(raw_response, attributes)
          @config = Config.new(nil, attributes[:config])
        end
      end
    end
  end
end
