# frozen_string_literal: true

module Modulr
  module Resources
    module Transfers
      class Transfer < Base
        map :id, [:id, :payment_reference_id]
        map :status, :status
        map :externalReference, :external_reference
      end
    end
  end
end
