# frozen_string_literal: true

module Modulr
  module API
    class NotificationsService < Service
      def find(id:, **opts)
        _response = client.get("#{base_notification_url(opts)}/notifications/#{id}")
      end

      def list(**opts)
        _response = client.get("#{base_notification_url(opts)}/notifications")
      end

      def create(type:, channel:, destinations:, config:, **opts)
        payload = {
          type: type,
          channel: channel,
          destinations: destinations,
          config: config,
        }
        _response = client.post("#{base_notification_url(opts)}/notifications", payload)
      end

      protected def base_notification_url(opts)
        opts[:partner_id] ? "/partners/#{opts[:partner_id]}" : "/customers/#{opts[:customer_id]}"
      end
    end
  end
end
