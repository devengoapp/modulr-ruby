# frozen_string_literal: true

module RSpecSupportHelpers
  def initialize_client(options = { apikey: "api_key", logger_enabled: false })
    Modulr::Client.new(options)
  end

  def http_fixture(*names)
    File.join(RSPEC_ROOT, "fixtures", *names)
  end

  def read_http_response_fixture(resource, fixture_name)
    file_name = [resource, "responses", "#{fixture_name}.http"].join("/")
    File.read(http_fixture(file_name))
  end
end

RSpec.configure do |config|
  config.include RSpecSupportHelpers
end
