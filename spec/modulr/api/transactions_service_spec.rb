# frozen_string_literal: true

RSpec.describe Modulr::API::TransactionsService, :unit, type: :client do
  subject(:transactions) { described_class.new(initialize_client) }

  describe "transactions list" do
    before do
      stub_request(:get, %r{/accounts/A0000001/transactions}).to_return(
        read_http_response_fixture("transactions/list", "success")
      )
    end

    let!(:list) { transactions.list(account_id: "A0000001") }

    it "builds correct request" do
      expect(WebMock).to have_requested(:get, %r{/accounts/A0000001/transactions}).with(
        headers: {
          "Authorization" => "api_key",
          "Content-Type" => "application/json",
        }
      )
    end

    it "returns transactions list" do
      expect(list).to be_a Modulr::Resources::Transactions::Transactions
    end

    context "with valid query parameters" do
      before do
        stub_request(:get, %r{/accounts/A0000001/transactions}).to_return(
          read_http_response_fixture("transactions/list", "success")
        )
      end

      let!(:list) { transactions.list(account_id: "A0000001", credit: true) }

      it_behaves_like "builds correct request", {
        method: :get,
        path: %r{/accounts/A0000001/transactions},
        query: { credit: "true" },
      }

      it "returns transactions list" do
        expect(list).to be_a Modulr::Resources::Transactions::Transactions
      end
    end

    context "with invalid query parameters" do
      before do
        stub_request(:get, %r{/accounts/A0000001/transactions}).to_return(
          read_http_response_fixture("transactions/list", "min_amount")
        )
      end

      it "raise the correct error" do
        expect { transactions.list(account_id: "A0000001", min_amount: -100) }.to(raise_error do |exception|
          expect(exception).to be_a(Modulr::RequestError)
          expect(exception.errors).not_to be_empty
          expect(exception.errors.select { |error| error[:field] == "minAmount" }).not_to be_empty
        end)
      end
    end
  end
end
