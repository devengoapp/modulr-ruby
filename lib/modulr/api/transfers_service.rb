# frozen_string_literal: true

module Modulr
  module API
    class TransfersService < Service
      def create( # rubocop:disable Metrics/ParameterLists
        account_id:,
        currency:,
        amount:,
        destination:,
        reference:,
        options: {}
      )
        data = {
          sourceAccountId: account_id,
          currency: currency,
          amount: amount,
          reference: reference,
          destination: {
            type: destination[:type],
            iban: destination[:iban],
            name: destination[:name],
          },
        }
        data[:externalReference] = options[:external_reference] if options[:external_reference]

        response = client.post("/payments", data, options)
        Resources::Transfers::Transfer.new(response, response.body[:data])
      end
    end
  end
end
