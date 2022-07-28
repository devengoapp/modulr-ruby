# frozen_string_literal: true

module Modulr
  module Resources
    module Payments
      class Payment < Base
        map :id, [:id, :payment_reference_id]
        map :status, :status
        map :externalReference, :external_reference
      end
    end
  end
end
