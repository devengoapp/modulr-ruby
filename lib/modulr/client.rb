# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "json"

require_relative "api/services"
require_relative "resources/base"

module Modulr
  class Client
    include Modulr::API::Services

    SANDBOX_URL = "https://api-sandbox.modulrfinance.com/api-sandbox-token"
    BASE_URL = SANDBOX_URL

    attr_reader :base_url, :origin, :proxy, :username, :logger_enabled

    def initialize(options = {})
      @base_url = options[:base_url] || BASE_URL
      @origin = options[:origin] || default_origin
      @proxy = options[:proxy]
      @apikey = options[:apikey] || ENV["MODULR_APIKEY"]
      @apisecret = options[:apisecret] || ENV["MODULR_APISECRET"]
      @logger_enabled = options[:logger_enabled].nil? ? true : options[:logger_enabled]
      @services = {}
    end

    def connection
      @connection ||= Faraday.new do |builder|
        builder.use Faraday::Response::RaiseError
        builder.response :json,
                         content_type: /\bjson$/,
                         preserve_raw: true,
                         parser_options: { symbolize_names: true }
        builder.proxy = @proxy if proxy
        if @logger_enabled
          builder.response :logger, nil, { headers: true, bodies: true } do |logger|
            logger.filter(/("password":)"(\w+)"/, '\1[FILTERED]')
          end
        end
        builder.adapter :net_http
      end
    end

    def get(path, options = {})
      execute :get, path, nil, options
    end

    def post(path, data = nil, options = {})
      execute :post, path, data, options
    end

    def put(path, data = nil, options = {})
      execute :put, path, data, options
    end

    def execute(method, path, data = nil, options = {})
      request(method, path, data, options)
    end

    def request(method, path, data = nil, options = {})
      request_options = request_options(method, path, data, options)
      uri = "#{base_url}#{path}"

      begin
        connection.run_request(method, uri, request_options[:body], request_options[:headers]) do |request|
          request.params.update(options) if options
        end
      rescue StandardError => e
        handle_request_error(e)
      end
    end

    def request_options(_method, _path, data, _options)
      default_options.tap do |defaults|
        add_auth_options!(defaults)
        defaults[:body] = JSON.dump(data) if data
      end
    end

    def add_auth_options!(options)
      return sandbox_auth_options(options) if @base_url.eql?(SANDBOX_URL)

      auth_options(options)
    end

    def sandbox_auth_options(options)
      options[:headers][:authorization] = @apikey
    end

    def auth_options(options)
      signature = Auth::Signature.calculate(apikey: @apikey, apisecret: @apisecret)
      options[:headers][:authorization] = signature.authorization
      options[:headers][:date] = signature.timestamp
      options[:headers][:"x-mod-nonce"] = signature.nonce
    end

    def handle_request_error(error)
      response = error.response
      case error
      when Faraday::ClientError
        case response[:status]
        when 403
          raise ForbiddenError, response
        when 404
          raise NotFoundError, response
        else
          raise RequestError, response
        end
      else
        raise Error, response
      end
    end

    def default_origin
      "Modulr/#{Modulr::VERSION} Ruby Client (Faraday/#{Faraday::VERSION})"
    end

    private def default_options
      {
        url: base_url,
        headers: {
          content_type: "application/json",
        },
      }
    end
  end
end
