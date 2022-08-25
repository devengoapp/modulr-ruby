# frozen_string_literal: true

RSpec.describe Modulr::API::TransactionsService, :unit, type: :client do
  subject(:transactions) { described_class.new(client) }

  let(:client) { initialize_client }

  describe "transactions history" do
    before do
      stub_request(:get, %r{/accounts/A0000001/transactions}).to_return(
        read_http_response_fixture("transactions/history", "success")
      )
    end

    let!(:history) { transactions.history(account_id: "A0000001") }

    it "builds correct request" do
      expect(WebMock).to have_requested(:get, %r{/accounts/A0000001/transactions}).with(
        headers: {
          "Authorization" => "api_key",
          "Content-Type" => "application/json",
        }
      )
    end

    it "returns transactions history" do
      expect(history).to be_a Modulr::Resources::Transactions::Transactions
    end
  end
end
