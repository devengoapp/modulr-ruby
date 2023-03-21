# frozen_string_literal: true

module Modulr
  module Resources
    class BaseCollection
      include Enumerable

      def initialize(item_klass, attributes_collection = [])
        @attributes_collection = attributes_collection
        @items = attributes_collection.map { |attributes_item| item_klass.new(attributes_item) }
      end

      def each(&block)
        @items.each(&block)
      end
    end
  end
end
