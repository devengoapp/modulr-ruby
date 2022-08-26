# frozen_string_literal: true

RSpec.describe Modulr::API::AccountsService, :unit, type: :client do
  subject(:accounts) { described_class.new(initialize_client) }

  describe "accounts create" do
    before do
      stub_request(:post, %r{/customers/C0000001/accounts}).to_return(
        read_http_response_fixture("accounts/create", "success")
      )
    end

    let!(:created_account) do
      accounts.create(
        customer_id: "C0000001",
        currency: "EUR",
        product_code: "productCode",
        options: { external_reference: "aReference_00001" }
      )
    end

    it_behaves_like "builds correct request", {
      method: :post,
      path: %r{/customers/C0000001/accounts},
      body: {
        currency: "EUR",
        productCode: "productCode",
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

  describe "accounts close" do
    before do
      stub_request(:post, %r{/accounts/A121AHGZ/close}).to_return(
        read_http_response_fixture("accounts/close", "success")
      )
    end

    let!(:method_response) do
      accounts.close(account_id: "A121AHGZ")
    end

    it_behaves_like "builds correct request", {
      method: :post,
      path: "https://api-sandbox.modulrfinance.com/api-sandbox-token/accounts/A121AHGZ/close",
    }

    it "returns nil" do
      expect(method_response).to be_nil
    end
  end
end
