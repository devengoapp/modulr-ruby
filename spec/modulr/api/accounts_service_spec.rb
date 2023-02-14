# frozen_string_literal: true

RSpec.describe Modulr::API::AccountsService, :unit, type: :client do
  subject(:accounts) { described_class.new(initialize_client) }

  describe "create account" do
    context "when the params are valid" do
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
          external_reference: "A new account in EUR"
        )
      end

      it_behaves_like "builds correct request", {
        method: :post,
        path: %r{/customers/C0000001/accounts},
        body: {
          currency: "EUR",
          productCode: "productCode",
          externalReference: "A new account in EUR",
        },
      }

      it "returns created account" do
        expect(created_account).to be_a Modulr::Resources::Accounts::Account
        expect(created_account.customer_id).to eql("C0000001")
        expect(created_account.external_reference).to eql("A new account in EUR")
        expect(created_account.balance).to eql("0.00")
        expect(created_account.available_balance).to be_nil
      end
    end

    context "when the currency is invalid" do
      before do
        stub_request(:post, %r{/customers/C0000001/accounts}).to_return(
          read_http_response_fixture("accounts/create", "invalid_currency_for_product")
        )
      end

      let!(:params) do
        {
          customer_id: "C0000001",
          currency: "JPY",
          product_code: "productCode",
          external_reference: "A new account in EUR",
        }
      end

      it "raise the correct error" do
        expect { accounts.create(**params) }.to raise_error Modulr::RequestError
      end
    end

    context "when product is not provided" do
      before do
        stub_request(:post, %r{/customers/C0000001/accounts}).to_return(
          read_http_response_fixture("accounts/create", "product_not_provided")
        )
      end

      let!(:params) do
        {
          customer_id: "C0000001",
          currency: "EUR",
          product_code: nil,
          external_reference: "A new account in EUR",
        }
      end

      it "raise the correct error" do
        expect { accounts.create(**params) }.to raise_error Modulr::RequestError
      end
    end
  end

  describe "find account" do
    context "when the id is valid" do
      before do
        stub_request(:get, %r{/accounts/A21C64X6}).to_return(
          read_http_response_fixture("accounts/find", "success")
        )
      end

      let!(:found_account) do
        accounts.find(id: "A21C64X6")
      end

      it_behaves_like "builds correct request", {
        method: :get,
        path: %r{/accounts/A21C64X6},
      }

      it "returns the account" do
        expect(found_account).to be_a Modulr::Resources::Accounts::Account
        expect(found_account.customer_id).to eql("C0000001")
        expect(found_account.external_reference).to eql("A new account in EUR")
        expect(found_account.balance).to eql("0.00")
        expect(found_account.available_balance).to eql("0.00")
      end
    end

    context "when id is invalid" do
      before do
        stub_request(:get, %r{/accounts/AAA}).to_return(
          read_http_response_fixture("accounts/find", "invalid_id")
        )
      end

      it "raise the correct error" do
        expect { accounts.find(id: "AAA") }.to raise_error Modulr::RequestError
      end
    end

    context "when id is not found" do
      before do
        stub_request(:get, %r{/accounts/A99C99X9}).to_return(
          read_http_response_fixture("accounts/find", "not_found")
        )
      end

      it "raise the correct error" do
        expect { accounts.find(id: "A99C99X9") }.to raise_error Modulr::NotFoundError
      end
    end
  end

  describe "close account" do
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
      path: %r{/accounts/A121AHGZ/close},
    }

    it "returns nil" do
      expect(method_response).to be_nil
    end
  end
end
