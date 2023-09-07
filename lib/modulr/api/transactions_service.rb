# frozen_string_literal: true

module Modulr
  module API
    class TransactionsService < Service
      def list(account_id:, **opts)
        response = client.get("/accounts/#{account_id}/transactions", build_query_params(opts))
        Resources::Transactions::Transactions.new(response.env[:raw_body], response.body[:content])
      end

      private def build_query_params(opts) # rubocop:disable Metrics/AbcSize
        same_name_params = [:credit, :type, :size, :page]
        date_params = { to: :toTransactionDate, from: :fromTransactionDate, to_posted: :toPostedDate,
                        from_posted: :fromPostedDate, }
        mapped_params = {
          source_id: :sourceId,
          description: :q,
          min_amount: :minAmount,
          max_amount: :maxAmount,
        }
        {}.tap do |params|
          same_name_params.each { |param| params[param] = opts[param] if opts[param] }
          date_params.each do |original, mapped|
            params[mapped] = format_datetime(opts[original]) if opts[original]
          end
          mapped_params.each { |original, mapped| params[mapped] = opts[original] if opts[original] }
        end
      end
    end
  end
end
