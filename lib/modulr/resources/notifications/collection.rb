# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Collection < BaseCollection
        def initialize(raw_response, attributes_collection)
          super(raw_response, Notification, attributes_collection)
        end
      end
    end
  end
end
