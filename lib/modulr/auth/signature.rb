# frozen_string_literal: true

require "base64"
require "date"
require "openssl"
require "securerandom"
require "erb"

module Modulr
  module Auth
    class Signature
      attr_reader :nonce, :signature, :timestamp, :authorization

      def initialize(apikey:, nonce:, signature:, timestamp:)
        @nonce = nonce
        @signature = signature
        @timestamp = timestamp
        @authorization = [
          "Signature keyId=\"#{apikey}\"",
          'algorithm="hmac-sha512"',
          'headers="date x-mod-nonce"',
          "signature=\"#{signature}\"",
        ].join(",")
      end

      def self.calculate(apikey:, apisecret:, nonce: SecureRandom.base64(30), timestamp: DateTime.now.httpdate)
        signature_string = "date: #{timestamp}\nx-mod-nonce: #{nonce}"
        digest = OpenSSL::HMAC.digest(
          "SHA512",
          apisecret.dup.force_encoding("UTF-8"),
          signature_string.dup.force_encoding("UTF-8")
        )
        b64 = Base64.strict_encode64(digest)
        url_safe_code = ERB::Util.url_encode(b64.strip)

        new(apikey: apikey, nonce: nonce, signature: url_safe_code, timestamp: timestamp)
      end
    end
  end
end
