# frozen_string_literal: true

module Modulr
  module API
    class Service
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def format_datetime(datetime)
        datetime.strftime("%Y-%m-%dT%H:%M:%S%z")
      end
    end
  end
end
