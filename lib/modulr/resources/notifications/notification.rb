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

        def initialize(attributes = {})
          super(attributes)
          @config = Config.new(attributes[:config])
        end
      end
    end
  end
end
