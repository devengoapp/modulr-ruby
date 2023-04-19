# Modulr FINAC API Ruby client

Ruby client for Modulr (cf. <https://modulr.readme.io/docs>)

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

## Usage

Run `bin/console` for an interactive prompt to experiment with the code.

### Customers

```rb
# Find a customer
client.customers.find(id: "C2188C26")

# Create a customer
client.customers.create(
  type: "LLC",
  legalEntity: "IE",
  name: "Your company SL.",
  expectedMonthlySpend: 99999,
  companyRegNumber: "TAXID",
  industryCode: "64929",
  tcsVersion: 1,
  tradingAddress: {
    addressLine1: "Fake Street 34",
    postTown: "Madrid",
    postCode: "28003",
    country: "ES",
  },
  registeredAddress: {
    addressLine1: "Fake Street 34",
    postTown: "Madrid",
    postCode: "28003",
    country: "ES",
  },
  associates: [
    {
      applicant: true,
      dateOfBirth: "1977-05-31",
      firstName: "Director Name",
      lastName: "Director Last Name",
      email: "director@yourcompany.com",
      phone: "+34677777777",
      type: "DIRECTOR",
      homeAddress: {
        addressLine1: "Fake Street 34",
        postTown: "Madrid",
        postCode: "28003",
        country: "ES",
      },
    },
    {
      applicant: false,
      dateOfBirth: "1976-08-14",
      firstName: "Owner Name",
      lastName: "Owner Last Name",
      type: "BENE_OWNER",
      ownership: 60,
      homeAddress: {
        addressLine1: "Fake Street 34",
        postTown: "Madrid",
        postCode: "28003",
        country: "ES",
      },
    },
  ]
)
```

### Accounts

```rb
# Find an account
client.accounts.find(id: "A2188C26")

# Create an account
client.accounts.create(customer_id: "C2188C26", currency: "EUR", product_code: "YOUR_PRODUCT_CODE", external_reference: "My new account")
```

### Payments

```rb
# Find a payment
client.payments.find(id: "P210FFT5AW")

# List payments
client.payments.list(from: DateTime.now - 1, to: DateTime.now)

# Create a payment
client.payments.create(account_id: "A2188C26", currency: "EUR", amount: 0.01, destination: { type: "IBAN", iban: "ES8601280011390100072676", name: "Aitor García Rey" }, reference: "The reference")
```

### Transactions

```rb
# List transactions
client.transactions.list(account_id: "A2188C26", credit: true)
```

### Notifications

### Supported event types per channel

Not all notifications can be sent to any channel. Check the following list for a quick view and the [original](https://modulr.readme.io/docs/notifications-1) reference for an up-to-date list

Supported via webhook:

- ACCOUNT_SWITCH_UPDATE
- DDMANDATE
- DD_FAILED_CLAIM
- DD_FUNDS_RETURNED
- DD_INCOMING_DEBIT
- DD_COLLECTION_STATUS
- PAYIN
- PAYOUT
- UPCOMING_CREDIT
- UPCOMING_COLLECTION_CREDIT
- UPCOMING_COLLECTION_DEBIT
- PAYMENT_COMPLIANCE_STATUS
- PAYMENT_FILE_UPLOAD

Supported via email:

- ACCOUNT_STATEMENT
- PENDING_PAYMENTS
- BALANCE
- CUSTVSTAT

```rb
# List setup notifications for a customer
client.notifications.list(customer_id: "C2188C26")

# Create a notification
client.notifications.create(
  customer_id: "C2188C26",
  type: "PAYOUT",
  channel: "WEBHOOK",
  destinations: [
    "https://yourwebsite.com/webhooks/endpoint"
  ],
  config: {
    retry: true,
    secret: "00000000000000000000000000000000",
    hmacAlgorithm: "hmac-sha512"
  })
```

## Release

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, on main branch update the version number in `version.rb`, then:

```git
bundle exec rake install
git add .
git commit -m 'Update version file and gemfile'
git push
git tag vx.x.x main
git push origin vx.x.x
```

The tagging will trigger the GitHub action defined in `release.yml`, pushing the gem to [rubygems.org](https://rubygems.org).

## Tooling for manual API testing

We have a tooling system based on HTTP request files which allow developers to run pre-format Modulr API requests easily. These HTTP request files are stored inside `doc/modulr_requests` directory. Find the service you want to run and run the specific HTTP file to execute the request locally.

We run these requests locally from our favorite IDEs, in our case, we use ([IntelliJ](https://www.jetbrains.com/es-es/idea/) or [VS Code](https://code.visualstudio.com/)). [IntelliJ](https://www.jetbrains.com/es-es/idea/) has a native feature that allows you to run these requests easily but if you are using [VS Code](https://code.visualstudio.com/) you will need to install the following extension [httpYac](https://marketplace.visualstudio.com/items?itemName=anweber.vscode-httpyac).

To configure the HTTP files system create a new `modulr-ruby/doc/modulr_requests/http-client.private.env.json` from `modulr-ruby/doc/modulr_requests/http-client.env.json` file.
Configure all variables by environment and you are ready to use your HTTP files.

## Testing

Any change should be tested. Builds with failures would not be allowed to merge.
To run your test suite locally using Rspec:

```rb
bundle exec rspec
```

To prepare your environment to listen for your local code changes use Guard instead:

```rb
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
