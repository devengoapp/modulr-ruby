# frozen_string_literal: true

module Modulr
  module API
    class NotificationsService < Service
      def find(id:, **opts)
        response = client.get("#{base_notification_url(opts)}/notifications/#{id}")
        Resources::Notifications::Notification.new(response.env[:raw_body], response.body)
      end

      def list(**opts)
        response = client.get("#{base_notification_url(opts)}/notifications")
        Resources::Notifications::Collection.new(response.env[:raw_body], response.body)
      end

      def create(type:, channel:, destinations:, config:, **opts)
        payload = {
          type: type,
          channel: channel,
          destinations: destinations,
          config: config,
        }
        response = client.post("#{base_notification_url(opts)}/notifications", payload)
        Resources::Notifications::Notification.new(response.env[:raw_body], response.body)
      end

      def update(id:, status:, destinations:, config:, **opts)
        payload = {
          status: status,
          destinations: destinations,
          config: config,
        }
        response = client.put("#{base_notification_url(opts)}/notifications/#{id}", payload)
        Resources::Notifications::Notification.new(response.env[:raw_body], response.body)
      end

      protected def base_notification_url(opts)
        opts[:partner_id] ? "/partners/#{opts[:partner_id]}" : "/customers/#{opts[:customer_id]}"
      end
    end
  end
end
