# frozen_string_literal: true

RSpec.describe Modulr::API::Services do
  let(:client) { initialize_client }

  it "includes all expected services" do
    expect(client.accounts).to be_an_instance_of(Modulr::API::AccountsService)
    expect(client.payments).to be_an_instance_of(Modulr::API::PaymentsService)
    expect(client.transactions).to be_an_instance_of(Modulr::API::TransactionsService)
  end
end
