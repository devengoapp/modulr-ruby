# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Collection < BaseCollection
        def initialize(response)
          super(response, Notification, response.body)
        end
      end
    end
  end
end
