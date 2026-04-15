# frozen_string_literal: true

require "uri"

module ModulrSpec
  module IdempotencyHelpers
    DEFAULT_TEST_APIKEY = "api_key"

    def modulr_idempotency_request_headers(idempotency_key, api_key: DEFAULT_TEST_APIKEY)
      {
        "Authorization" => api_key,
        "Content-Type" => "application/json",
        "x-mod-nonce" => Modulr::Client.idempotency_nonce(idempotency_key),
        "x-mod-retry" => "true",
      }
    end

    def stub_modulr_apikey_env_for_idempotency(api_key = DEFAULT_TEST_APIKEY)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("MODULR_APIKEY").and_return(api_key)
    end

    def modulr_request_query_excludes_idempotency_key?(request)
      q = URI(request.uri).query
      q.nil? || !q.include?("idempotency")
    end
  end
end

RSpec.configure do |config|
  config.include ModulrSpec::IdempotencyHelpers
end
