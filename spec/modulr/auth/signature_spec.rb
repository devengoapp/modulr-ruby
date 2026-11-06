# frozen_string_literal: true

RSpec.describe Modulr::Auth::Signature, :unit do
  describe ".calculate" do
    subject(:signature) do
      described_class.calculate(apikey: "test-key", apisecret: "test-secret", nonce: nonce, timestamp: timestamp)
    end

    let(:nonce) { "28154b2-9c62b93cc22a-24c9e2-5536d7d" }
    let(:timestamp) { "Mon, 25 Jul 2016 16:36:07 GMT" }
    # Computed with the openssl CLI, independently of this code:
    # printf 'date: <timestamp>\nx-mod-nonce: <nonce>' | openssl dgst -sha512 -hmac test-secret -binary | base64
    # then URL-encoded.
    let(:expected_signature) do
      "LNWu18Yq42Kehe0BlQoRBZdTOH%2BjaiNxT8ShLLsY4f5qATjWuBf1AOyEJ9%2BvIiy0qO0qPAJMP59CzpQsyLxs1Q%3D%3D"
    end

    it "signs the date and nonce with HMAC-SHA512 and builds the Authorization header", :aggregate_failures do
      expect(signature.signature).to eq(expected_signature)
      expect(signature.authorization).to eq(
        'Signature keyId="test-key",algorithm="hmac-sha512",headers="date x-mod-nonce",' \
        "signature=\"#{expected_signature}\""
      )
      expect(signature.nonce).to eq(nonce)
      expect(signature.timestamp).to eq(timestamp)
    end

    context "without nonce and timestamp" do
      subject(:signature) { described_class.calculate(apikey: "test-key", apisecret: "test-secret") }

      it "generates a random nonce" do
        other = described_class.calculate(apikey: "test-key", apisecret: "test-secret")

        expect(signature.nonce).to be_a(String).and(satisfy { |n| n.length >= 40 })
        expect(signature.nonce).not_to eq(other.nonce)
      end

      it "uses the current time as an HTTP date" do
        expect(Time.httpdate(signature.timestamp)).to be_within(5).of(Time.now)
      end
    end
  end
end
