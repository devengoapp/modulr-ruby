# frozen_string_literal: true

module Modulr
  module API
    class CustomersService < Service
      def find(id:)
        response = client.get("/customers/#{id}")
        Resources::Customers::Customer.new(response)
      end
    end
  end
end
