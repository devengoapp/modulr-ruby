# frozen_string_literal: true

module Modulr
  module API
    module Services
      def accounts
        @services[:accounts] ||= API::AccountsService.new(self)
      end
    end
  end
end
