# frozen_string_literal: true

require_relative "lib/modulr/version"

Gem::Specification.new do |spec|
  spec.name = "modulr-api"
  spec.version = Modulr::VERSION
  spec.authors = ["Aitor García Rey"]
  spec.email = ["aitor@devengo.com"]

  spec.summary = "Ruby client for Modulr Finance API."
  spec.description = "Ruby client for Modulr Finance API."
  spec.homepage = "https://github.com/devengoapp/modulr-ruby"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/devengoapp/modulr-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/devengoapp/modulr-ruby/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 1.0"
  spec.add_dependency "faraday_middleware", "~> 1.0"
  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_development_dependency "guard", "~> 2.0"
  spec.add_development_dependency "guard-rspec", "~> 4.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.0"
  spec.add_development_dependency "rubocop-rake", "~> 0.1"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
  spec.add_development_dependency "test-prof", "~> 1.0"
  spec.add_development_dependency "webmock", "~> 2.1"
end
