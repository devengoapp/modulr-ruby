# frozen_string_literal: true

module Modulr
  module Resources
    module Transfers
      class Transfer < Base
        attr_accessor :id, :externalReference, :status # rubocop:disable Naming/MethodName

        alias payment_reference_id id
        alias external_reference externalReference
      end
    end
  end
end
