# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  skip "/spec/"
  # Only on CI: a partial local run would always be below the minimum.
  minimum_coverage line: 98, branch: 80 if ENV["CI"]
end

require "modulr"
require "yaml"

RSPEC_ROOT = File.expand_path(__dir__) unless defined?(RSPEC_ROOT)
Dir[File.join(RSPEC_ROOT, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
