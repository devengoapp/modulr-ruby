# frozen_string_literal: true

module Modulr
  module API
    class TransfersService < Service
      def create( # rubocop:disable Metrics/ParameterLists
        account_id:,
        currency:,
        amount:,
        destination_type:,
        destination_iban:,
        destination_name:,
        reference:,
        options: {}
      )
        data = {
          sourceAccountId: account_id,
          currency: currency,
          amount: amount,
          reference: reference,
          destination: {
            type: destination_type,
            iban: destination_iban,
            name: destination_name,
          },
        }
        data[:externalReference] = options[:external_reference] if options[:external_reference]

        response = client.post("/payments", data, options)
        Resources::Transfers::Transfer.new(response, response.body[:data])
      end
    end
  end
end
