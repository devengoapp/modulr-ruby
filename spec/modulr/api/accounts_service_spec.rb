# frozen_string_literal: true

RSpec.describe Modulr::API::AccountsService, :unit, type: :client do
  subject(:accounts) { described_class.new(client) }

  let(:client) { initialize_client }
  let(:options) { { external_reference: "aReference_00001" } }
  let(:customer_id) { "C0000001" }

  describe "accounts create" do
    before do
      stub_request(:post, %r{/customers/C0000001/accounts}).to_return(
        read_http_response_fixture("accounts/create", "success")
      )
    end

    let!(:created_account) { accounts.create(customer_id: customer_id, options: options) }

    it_behaves_like "builds correct request", {
      method: :post,
      path: %r{/customers/C0000001/accounts},
      body: {
        currency: "EUR",
        productCode: "O1200001",
        externalReference: "aReference_00001",
      },
    }

    it "returns created account" do
      expect(created_account).to be_a Modulr::Resources::Accounts::Account
      expect(created_account.customer_id).to eql("C0000001")
      expect(created_account.external_reference).to eql("aReference_00001")
      expect(created_account.balance).to eql("0.00")
      expect(created_account.available_balance).to be_nil
    end
  end
end
