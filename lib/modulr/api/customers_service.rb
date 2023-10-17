# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

module Modulr
  module API
    class CustomersService < Service
      def find(id:)
        response = client.get("/customers/#{id}")
        attributes = response.body

        Resources::Customers::Customer.new(response, attributes)
      end

      def create(type:, legal_entity:, **opts)
        payload = {
          type: type,
          legalEntity: legal_entity,
        }

        payload[:externalReference] = opts[:external_reference] if opts[:external_reference]
        payload[:name] = opts[:name] if opts[:name]
        payload[:companyRegNumber] = opts[:company_reg_number] if opts[:company_reg_number]
        payload[:registeredAddress] = opts[:registered_address] if opts[:registered_address]
        payload[:tradingAddress] = opts[:trading_address] if opts[:trading_address]
        payload[:industryCode] = opts[:industry_code] if opts[:industry_code]
        payload[:tcsVersion] = opts[:tcs_version] if opts[:tcs_version]
        payload[:expectedMonthlySpend] = opts[:expected_monthly_spend] if opts[:expected_monthly_spend]
        payload[:associates] = opts[:associates] if opts[:associates]
        payload[:documentInfo] = opts[:document_info] if opts[:document_info]
        payload[:provisionalCustomerId] = opts[:provisional_customer_id] if opts[:provisional_customer_id]
        payload[:customerTrust] = opts[:customer_trust] if opts[:customer_trust]
        payload[:taxProfile] = opts[:tax_profile] if opts[:tax_profile]

        response = client.post("/customers", payload)
        attributes = response.body

        Resources::Customers::Customer.new(response, attributes)
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
