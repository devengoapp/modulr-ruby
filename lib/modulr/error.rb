# frozen_string_literal: true

module Modulr
  class Error < StandardError
  end

  class RequestError < Error
    attr_reader :response, :errors

    def initialize(response)
      @response = response
      @errors = extract_errors
      super(message_from(response))
    end

    private def extract_errors
      return unless json?

      response[:body]
    end

    private def message_from(response)
      return response if response.is_a?(String)

      if errors
        errors.map { |error| "#{error[:field]} #{error[:code]} #{error[:message]}" }.join(", ")
      else

        "#{response[:status]} #{response[:body]}"
      end
    end

    private def json?
      return unless response.is_a?(Hash)

      content_type = response[:headers]["content-type"]
      content_type&.start_with?("application/json")
    end
  end

  class NotFoundError < RequestError
  end

  class ForbiddenError < RequestError
  end
end
