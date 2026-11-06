# frozen_string_literal: true

module Modulr
  module Resources
    class BaseCollection
      attr_reader :response

      include Enumerable

      def initialize(response, item_klass, attributes_collection = [])
        @response = response
        @items = attributes_collection.map { |attributes| item_klass.new(nil, attributes) }
      end

      def each(&)
        @items.each(&)
      end
    end
  end
end
