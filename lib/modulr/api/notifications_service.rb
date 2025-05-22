# frozen_string_literal: true

module Modulr
  module API
    class NotificationsService < Service
      def find(id:, **opts)
        url = File.join(base_notification_url(opts), "notifications", id.to_s)
        response = client.get(url)
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      def list(**opts)
        url = File.join(base_notification_url!(opts), "notifications")
        response = client.get(url)
        attributes_collection = response.body

        Resources::Notifications::Collection.new(response, attributes_collection)
      end

      def create(type:, channel:, destinations:, config:, **opts)
        payload = {
          type: type,
          channel: channel,
          destinations: destinations,
          config: config,
        }
        url = File.join(base_notification_url!(opts), "notifications")
        response = client.post(url, payload)
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      def update(id:, status:, destinations:, config:, **opts)
        payload = {
          status: status,
          destinations: destinations,
          config: config,
        }
        url = File.join(base_notification_url!(opts), "notifications", id.to_s)
        response = client.put(url, payload)
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      protected def base_notification_url(opts)
        opts[:partner_id] ? "/partners/#{opts[:partner_id]}" : "/customers/#{opts[:customer_id]}"
      end
    end
  end
end
