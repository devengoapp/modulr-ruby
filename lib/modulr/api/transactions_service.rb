# frozen_string_literal: true

module Modulr
  module API
    class TransactionsService < Service
      def list(account_id:, **opts)
        response = client.get("/accounts/#{account_id}/transactions", build_query_params(opts))
        Resources::Transactions::Transactions.new(response, response.body[:content])
      end

      private def build_query_params(opts)
        same_name_params = [:id, :amount, :currency, :description, :credit, :type]
        transactions_date_params = { to: :toTransactionDate, from: :fromTransactionDate}
        # posted_date_params = { to: :toPostedDate, from: :fromPostedDate}
        # amount_params = {to: :minAmount, from: :maxAmount}
        mapped_params = {
          created_at: :transactionDate,
          date: :postedDate,
          source_id: :sourceId,
          external_reference: :sourceExternalReference,
          additional_info: :additionalInfo,
        }
        {}.tap do |params|
          same_name_params.each { |param| params[param] = opts[param] if opts[param] }
          transactions_date_params.each { |original, mapped| params[mapped] = format_datetime(opts[original]) if opts[original] }
          mapped_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
        end
      end
    end
  end
end
