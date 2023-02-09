# frozen_string_literal: true

require_relative "modulr/version"

require_relative "modulr/auth/signature"

require_relative "modulr/api/service"
require_relative "modulr/api/services"
require_relative "modulr/api/accounts_service"
require_relative "modulr/api/customers_service"
require_relative "modulr/api/payments_service"
require_relative "modulr/api/notifications_service"

require_relative "modulr/resources/base"
require_relative "modulr/resources/collection"
require_relative "modulr/resources/accounts/account"
require_relative "modulr/resources/accounts/identifier"
require_relative "modulr/resources/accounts/identifiers"
require_relative "modulr/resources/customers/customer"

require_relative "modulr/error"
require_relative "modulr/client"
