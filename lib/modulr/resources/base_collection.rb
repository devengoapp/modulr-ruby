# frozen_string_literal: true

module Modulr
  module Resources
    class BaseCollection
      attr_reader :raw_response

      include Enumerable

      def initialize(response, item_klass, attributes_collection = [])
        @raw_response = response.nil? ? nil : response.env[:raw_body]
        @items = attributes_collection.map { |attributes| item_klass.new(nil, attributes) }
      end

      def each(&block)
        @items.each(&block)
      end
    end
  end
end
