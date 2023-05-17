# frozen_string_literal: true

module Modulr
  module Resources
    module Accounts
      class Identifier < Base
        map :type
        map :id
        map :iban
        map :bic
        map :currency
        map :accountNumber, :account_number
        map :sortCode, :sort_code
        map :countrySpecificDetails, :country_details
        map :providerExtraInfo, :provider_extra_info
      end
    end
  end
end
