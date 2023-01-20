# frozen_string_literal: true

module Modulr
  module API
    class PaymentsService < Service
      def find(id:)
        _response = client.get("/payments", { id: id} )
      end

      def list(**opts)
        return find(id: opts[:id] ) if opts[:id]

        params = {}
        params[:fromCreatedDate] = format_datetime(opts[:from]) if opts[:from]
        params[:toCreatedDate] = format_datetime(opts[:to]) if opts[:to]
        params[:type] = opts[:type] if opts[:type]
        params[:externalReference] = opts[:external_reference] if opts[:external_reference]
        params[:status] = opts[:status] if opts[:status]
        params[:sourceAccountId] = opts[:account_id] if opts[:account_id]

        _response = client.get("/payments", params)
      end


      def create(account_id:, destination:, reference:, currency:, amount:, **opts)
        payload = {
          sourceAccountId: account_id,
          destination: destination,
          reference: reference,
          currency: currency,
          amount: amount,
        }

        _response = client.post("/payments", payload)
      end
    end
  end
end
