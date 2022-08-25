# Modulr FINAC API Ruby client

Ruby client for Modulr (cf. <https://modulr.readme.io/docs>)

Run `bin/console` for an interactive prompt to experiment with the code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "modulr-api"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install modulr-api
```

## Release

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then tag and push the new version:

```git
git tag vx.x.x main
git push origin vx.x.x
```

The tagging will trigger the GitHub action defined in `release.yml`, pushing the gem to [rubygems.org](https://rubygems.org).

## Tooling

We have a tooling system based on HTTP request files which allow developers to run pre-format Modulr API requests easily. These HTTP request files are stored inside `doc/modulr_requests` directory. Find the service you want to run and run the specific HTTP file to execute the request locally.

We run these requests locally from our favorite IDEs, in our case, we use ([IntelliJ](https://www.jetbrains.com/es-es/idea/) or [VS Code](https://code.visualstudio.com/)). [IntelliJ](https://www.jetbrains.com/es-es/idea/) has a native feature that allows you to run these requests easily but if you are using [VS Code](https://code.visualstudio.com/) you will need to install the following extension [httpYac](https://marketplace.visualstudio.com/items?itemName=anweber.vscode-httpyac).

To configure the HTTP files system create a new `modulr-ruby/doc/modulr_requests/http-client.private.env.json` from `modulr-ruby/doc/modulr_requests/http-client.env.json` file.
Configure all variables by environment and you are ready to use your HTTP files.

## Testing

Any change should be tested. Builds with failures would not be allowed to merge.
To run your test suite locally using Rspec:

```ruby
bundle exec rspec
```

To prepare your environment to listen for your local code changes use Guard instead:

```ruby
bundle exec guard
```

To test services, we have a spec system that uses the [Webmock](https://github.com/bblimke/webmock) library to stub requests and checks them against service response HTTP format files.
These HTTP files are stored in the `spec/fixtures` directory.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/devengoapp/modulr-ruby>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/devengoapp/modulr-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Modulr project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/devengoapp/modulr-ruby/blob/main/CODE_OF_CONDUCT.md).
