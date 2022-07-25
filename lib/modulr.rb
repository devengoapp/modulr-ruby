# frozen_string_literal: true

require_relative "modulr/version"

require_relative "modulr/auth/signature"
require_relative "modulr/client"

module Modulr
  class Error < StandardError; end
end
