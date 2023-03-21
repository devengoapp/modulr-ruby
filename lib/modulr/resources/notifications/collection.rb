# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Collection < BaseCollection
        def initialize(attributes_collection)
          super(Notification, attributes_collection)
        end
      end
    end
  end
end
