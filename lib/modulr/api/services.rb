# frozen_string_literal: true

require_relative "service"
require_relative "accounts_service"
require_relative "transfers_service"

module Modulr
  module API
    module Services
      def accounts
        @services[:accounts] ||= API::AccountsService.new(self)
      end

      def transfers
        @services[:transfers] ||= API::TransfersService.new(self)
      end
    end
  end
end
