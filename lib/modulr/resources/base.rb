# frozen_string_literal: true

module Modulr
  module Resources
    class Base
      attr_reader :response

      def initialize(response, attributes = {})
        @response = response
        attributes.each do |key, value|
          m = "#{key}=".to_sym
          send(m, value) if respond_to?(m)
        end
      end

      def self.map(original_attribute, mapped_attributes)
        class_eval { attr_writer original_attribute.to_sym }
        mapped_attributes = [mapped_attributes].flatten
        mapped_attributes.each do |mapped_attribute|
          define_method(mapped_attribute) { instance_variable_get("@#{original_attribute}") }
        end
      end
    end
  end
end

require_relative "collection"
require_relative "accounts/account"
require_relative "accounts/identifier"
require_relative "accounts/identifiers"
require_relative "payments/payment"
require_relative "transactions/transactions"
require_relative "transactions/transaction"
