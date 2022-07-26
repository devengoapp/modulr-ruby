# frozen_string_literal: true

require_relative "service"
require_relative "accounts_service"
require_relative "payments_service"

module Modulr
  module API
    module Services
      def accounts
        @services[:accounts] ||= API::AccountsService.new(self)
      end

      def payments
        @services[:payments] ||= API::PaymentsService.new(self)
      end
    end
  end
end
