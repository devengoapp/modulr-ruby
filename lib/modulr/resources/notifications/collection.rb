# frozen_string_literal: true

module Modulr
  module Resources
    module Notifications
      class Collection < BaseCollection
        def initialize(response)
          attributes_collection = response.body

          super(response, Notification, attributes_collection)
        end
      end
    end
  end
end
