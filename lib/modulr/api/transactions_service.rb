# frozen_string_literal: true

module Modulr
  module API
    class TransactionsService < Service
      def list(account_id:, **opts)
        response = client.get("/accounts/#{account_id}/transactions", build_query_params(opts))
        Resources::Transactions::Transactions.new(response, response.body[:content])
      end

      private def build_query_params(opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        same_name_params = [:credit, :type]
        transactions_date_params = { to: :toTransactionDate, from: :fromTransactionDate }
        posted_date_params = { to_posted: :toPostedDate, from_posted: :fromPostedDate }
        amount_params = { to_min: :minAmount, from_max: :maxAmount }
        description_params = { description: :q }
        mapped_params = {
          source_id: :sourceId,
        }
        {}.tap do |params|
          same_name_params.each { |param| params[param] = opts[param] if opts[param] }
          transactions_date_params.each do |original, mapped|
            params[mapped] = format_datetime(opts[original]) if opts[original]
          end
          posted_date_params.each do |original, mapped|
            params[mapped] = format_datetime(opts[original]) if opts[original]
          end
          amount_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
          description_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
          mapped_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
        end
      end
    end
  end
end
