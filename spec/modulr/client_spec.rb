# frozen_string_literal: true

require "base64"
require "openssl"

RSpec.describe Modulr::Client, :unit do
  let(:client) { initialize_client }

  describe ".idempotency_nonce" do
    before { stub_modulr_apikey_env_for_idempotency("api_key") }

    it "returns url-safe Base64 HMAC-SHA256(idempotency_key) with secret MODULR_APIKEY" do
      idempotency_key = "client-spec-op-789"
      expected = Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest(OpenSSL::Digest.new("SHA256"), "api_key", idempotency_key)
      )
      expect(described_class.idempotency_nonce(idempotency_key)).to eq(expected)
    end

    it "is stable for the same inputs" do
      expect(described_class.idempotency_nonce("same-key")).to eq(described_class.idempotency_nonce("same-key"))
    end
  end

  describe "#get" do
    before do
      stub_request(:get, %r{/test})
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })
    end

    it "requests the path with sandbox authorization and JSON content type" do
      client.get("/test")

      expect(WebMock).to have_requested(:get, %r{/test}).with(
        headers: {
          "Authorization" => "api_key",
          "Content-Type" => "application/json",
        },
      )
    end

    it "does not add a query string when no options are passed" do
      client.get("/test")

      expect(WebMock).to have_requested(:get, %r{/test}).with { |req|
        req.uri.query.nil?
      }
    end

    it "merges options into the query string" do
      client.get(
        "/test",
        {
          filter: "active",
          page: 0,
          limit: 20,
        },
      )

      expect(WebMock).to have_requested(:get, %r{/test}).with(
        query: hash_including(
          "filter" => "active",
          "page" => "0",
          "limit" => "20",
        ),
      )
    end

    it "does not send a body" do
      client.get("/test", { q: "x" })

      expect(WebMock).to have_requested(:get, %r{/test}).with { |req|
        req.body.nil? || req.body.to_s.empty?
      }
    end

    context "when idempotency_key is provided in options" do
      before { stub_modulr_apikey_env_for_idempotency }

      let(:idempotency_key) { "get-ignores-idempotency-key" }

      it "does not send x-mod-nonce or x-mod-retry headers" do
        client.get("/test", { q: "a", idempotency_key: idempotency_key })

        expect(WebMock).to have_requested(:get, %r{/test}).with { |req|
          keys = (req.headers || {}).keys.map { |k| k.to_s.downcase }
          keys.none? { |k| k == "x-mod-nonce" || k == "x-mod-retry" }
        }
      end

      it "does not include idempotency_key in the query string" do
        client.get("/test", { filter: "x", idempotency_key: idempotency_key })

        expect(WebMock).to have_requested(:get, %r{/test}).with { |req|
          q = req.uri.query.to_s
          !q.include?("idempotency") && q.include?("filter")
        }
      end
    end
  end

  describe "#post" do
    context "when idempotency_key is provided in options" do
      before do
        stub_request(:post, %r{/test}).to_return(
          status: 200,
          body: "{}",
          headers: { "Content-Type" => "application/json" },
        )
        stub_modulr_apikey_env_for_idempotency
      end

      let(:idempotency_key) { "post-idempotency-client-spec" }

      let(:payload) do
        {
          resource: "example",
          amount: "1.0",
          nested: { type: "A", code: "x" },
        }
      end

      it "sends x-mod-nonce and x-mod-retry derived from idempotency_key" do
        client.post("/test", payload, idempotency_key: idempotency_key)

        expect(WebMock).to have_requested(:post, %r{/test}).with(
          headers: modulr_idempotency_request_headers(idempotency_key),
          body: {
            resource: "example",
            amount: "1.0",
            nested: { type: "A", code: "x" },
          },
        )
      end

      it "does not put idempotency_key on the query string" do
        client.post("/test", { foo: "bar" }, idempotency_key: idempotency_key)
        expect(WebMock).to have_requested(:post, %r{/test}).with { |req|
          modulr_request_query_excludes_idempotency_key?(req)
        }
      end
    end
  end

  describe "#put" do
    context "when idempotency_key is provided in options" do
      before do
        stub_request(:put, %r{/test}).to_return(
          status: 200,
          body: "{}",
          headers: { "Content-Type" => "application/json" },
        )
        stub_modulr_apikey_env_for_idempotency
      end

      let(:idempotency_key) { "put-idempotency-client-spec" }

      it "sends the same idempotency headers as post" do
        client.put(
          "/test",
          { state: "paused", tags: [], meta: {} },
          idempotency_key: idempotency_key,
        )

        expect(WebMock).to have_requested(:put, %r{/test}).with(
          headers: modulr_idempotency_request_headers(idempotency_key),
          body: {
            state: "paused",
            tags: [],
            meta: {},
          },
        )
      end
    end
  end
end
