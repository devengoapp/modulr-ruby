# frozen_string_literal: true

module Modulr
  class Error < StandardError
    attr_reader :wrapped_error, :status, :response

    def initialize(error)
      @wrapped_error = error
      @response = @wrapped_error.response
      @status = structured_response[:status]
      super(error_message)
    end

    private def error_message
      return @wrapped_error unless @response

      wrapped_error_description = "#{@wrapped_error.class}: #{@wrapped_error}"
      response_description = "Status: #{structured_response[:status]} - Response: '#{structured_response[:body]}'"
      "#{response_description} (#{wrapped_error_description})"
    end

    private def structured_response
      return {} unless @response
      return @response if @response.is_a?(Hash)

      {
        status: @response.status,
        body: @response.body,
      }
    end
  end

  class ClientError < Error
  end

  class ServerError < Error
  end
end
