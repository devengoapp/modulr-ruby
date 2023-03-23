# frozen_string_literal: true

module Modulr
  module Resources
    class BaseCollection
      attr_reader :raw_response

      include Enumerable

      def initialize(raw_response, item_klass, attributes_collection = [])
        @raw_response = raw_response
        @attributes_collection = attributes_collection
        @items = attributes_collection.map { |attributes_item| item_klass.new(nil, attributes_item) }
      end

      def each(&block)
        @items.each(&block)
      end
    end
  end
end
