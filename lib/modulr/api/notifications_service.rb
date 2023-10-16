# frozen_string_literal: true

module Modulr
  module API
    class NotificationsService < Service
      def find(id:, **opts)
        response = client.get("#{base_notification_url(opts)}/notifications/#{id}")
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      def list(**opts)
        response = client.get("#{base_notification_url(opts)}/notifications")
        Resources::Notifications::Collection.new(response)
      end

      def create(type:, channel:, destinations:, config:, **opts)
        payload = {
          type: type,
          channel: channel,
          destinations: destinations,
          config: config,
        }
        response = client.post("#{base_notification_url(opts)}/notifications", payload)
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      def update(id:, status:, destinations:, config:, **opts)
        payload = {
          status: status,
          destinations: destinations,
          config: config,
        }
        response = client.put("#{base_notification_url(opts)}/notifications/#{id}", payload)
        attributes = response.body

        Resources::Notifications::Notification.new(response, attributes)
      end

      protected def base_notification_url(opts)
        opts[:partner_id] ? "/partners/#{opts[:partner_id]}" : "/customers/#{opts[:customer_id]}"
      end
    end
  end
end
