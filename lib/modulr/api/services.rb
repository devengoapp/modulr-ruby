# frozen_string_literal: true

module Modulr
  module API
    module Services
      def accounts
        @services[:accounts] ||= API::AccountsService.new(self)
      end

      def customers
        @services[:customers] ||= API::CustomersService.new(self)
      end

      def payments
        @services[:payments] ||= API::PaymentsService.new(self)
      end

      def notifications
        @services[:notifications] ||= API::NotificationsService.new(self)
      end
    end
  end
end
