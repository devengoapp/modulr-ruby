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

    it "is deterministic for the same idempotency_key" do
      key = "same-key"
      first_nonce = described_class.idempotency_nonce(key)
      second_nonce = described_class.idempotency_nonce(key)
      expect(first_nonce).to eq(second_nonce)
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
        }
      )
    end

    it "does not add a query string when no options are passed" do
      client.get("/test")

      expect(WebMock).to(
        have_requested(:get, %r{/test}).with do |req|
          req.uri.query.nil?
        end
      )
    end

    it "merges options into the query string" do
      client.get(
        "/test",
        {
          filter: "active",
          page: 0,
          limit: 20,
        }
      )

      expect(WebMock).to have_requested(:get, %r{/test}).with(
        query: hash_including(
          "filter" => "active",
          "page" => "0",
          "limit" => "20"
        )
      )
    end

    it "does not send a body" do
      client.get("/test", { q: "x" })

      expect(WebMock).to(
        have_requested(:get, %r{/test}).with do |req|
          req.body.nil? || req.body.to_s.empty?
        end
      )
    end

    context "when idempotency_key is provided in options" do
      before { stub_modulr_apikey_env_for_idempotency }

      let(:idempotency_key) { "get-ignores-idempotency-key" }

      it "does not send x-mod-nonce or x-mod-retry headers" do
        client.get("/test", { q: "a", idempotency_key: idempotency_key })

        idempotency_header_names = %w[x-mod-nonce x-mod-retry]
        expect(WebMock).to(
          have_requested(:get, %r{/test}).with do |req|
            keys = (req.headers || {}).keys.map { |k| k.to_s.downcase }
            keys.none? { |k| idempotency_header_names.include?(k) }
          end
        )
      end

      it "does not include idempotency_key in the query string" do
        client.get("/test", { filter: "x", idempotency_key: idempotency_key })

        expect(WebMock).to(
          have_requested(:get, %r{/test}).with do |req|
            q = req.uri.query.to_s
            !q.include?("idempotency") && q.include?("filter")
          end
        )
      end
    end
  end

  describe "#post" do
    context "when idempotency_key is provided in options" do
      before do
        stub_request(:post, %r{/test}).to_return(
          status: 200,
          body: "{}",
          headers: { "Content-Type" => "application/json" }
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
          }
        )
      end

      it "does not put idempotency_key on the query string" do
        client.post("/test", { foo: "bar" }, idempotency_key: idempotency_key)
        expect(WebMock).to(
          have_requested(:post, %r{/test}).with do |req|
            modulr_request_query_excludes_idempotency_key?(req)
          end
        )
      end
    end
  end

  describe "#put" do
    context "when idempotency_key is provided in options" do
      before do
        stub_request(:put, %r{/test}).to_return(
          status: 200,
          body: "{}",
          headers: { "Content-Type" => "application/json" }
        )
        stub_modulr_apikey_env_for_idempotency
      end

      let(:idempotency_key) { "put-idempotency-client-spec" }

      it "sends the same idempotency headers as post" do
        client.put(
          "/test",
          { state: "paused", tags: [], meta: {} },
          idempotency_key: idempotency_key
        )

        expect(WebMock).to have_requested(:put, %r{/test}).with(
          headers: modulr_idempotency_request_headers(idempotency_key),
          body: {
            state: "paused",
            tags: [],
            meta: {},
          }
        )
      end
    end
  end

  describe "Faraday error mapping" do
    let(:client) { initialize_client }
    let(:faraday_connection) { instance_double(Faraday::Connection) }

    before do
      allow(client).to receive(:connection).and_return(faraday_connection)
    end

    context "when Faraday raises ClientError" do
      let(:faraday_error) { Faraday::ClientError.new("the server responded with status 404") }

      before do
        allow(faraday_connection).to receive(:run_request).and_raise(faraday_error)
      end

      it "raises Modulr::ClientError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::ClientError)
      end

      it "wraps the original Faraday::ClientError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::ClientError) do |error|
          expect(error.wrapped_error).to be(faraday_error)
        end
      end
    end

    context "when Faraday raises ServerError" do
      let(:faraday_error) { Faraday::ServerError.new("the server responded with status 503") }

      before do
        allow(faraday_connection).to receive(:run_request).and_raise(faraday_error)
      end

      it "raises Modulr::ServerError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::ServerError)
      end

      it "wraps the original Faraday::ServerError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::ServerError) do |error|
          expect(error.wrapped_error).to be(faraday_error)
        end
      end
    end

    context "when Faraday raises TimeoutError" do
      before do
        allow(faraday_connection).to receive(:run_request).and_raise(
          Faraday::TimeoutError.new("execution expired")
        )
      end

      it "raises Modulr::TimeoutError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::TimeoutError)
      end

      it "wraps the original Faraday::TimeoutError" do
        expect { client.get("/any-path") }.to raise_error(Modulr::TimeoutError) do |error|
          expect(error.wrapped_error).to be_a(Faraday::TimeoutError)
          expect(error.wrapped_error.message).to eq("execution expired")
        end
      end
    end

    context "when Faraday raises another StandardError (e.g. connection failure)" do
      let(:faraday_error) { Faraday::ConnectionFailed.new("Connection refused") }

      before do
        allow(faraday_connection).to receive(:run_request).and_raise(faraday_error)
      end

      it "raises Modulr::Error" do
        expect { client.get("/any-path") }.to raise_error(Modulr::Error)
      end

      it "does not raise a specialized Modulr client subclass" do
        expect { client.get("/any-path") }.to raise_error(Modulr::Error) do |error|
          expect(error).not_to be_a(Modulr::ClientError)
          expect(error).not_to be_a(Modulr::ServerError)
          expect(error).not_to be_a(Modulr::TimeoutError)
        end
      end

      it "wraps the original exception" do
        expect { client.get("/any-path") }.to raise_error(Modulr::Error) do |error|
          expect(error.wrapped_error).to be(faraday_error)
        end
      end
    end
  end
end
