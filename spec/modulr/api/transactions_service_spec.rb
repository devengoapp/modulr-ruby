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

    context "with incoming transactions" do
      before do
        stub_request(:get, %r{/accounts/#{account}/transactions}).to_return(
          read_http_response_fixture("transactions/list", fixture_name)
        )
      end

      context "when it is a UK faster payment" do
        let(:account) { "A1229ZQJ" }
        let(:fixture_name) { "incoming/success_faster_transactions" }
        let!(:transaction) { transactions.list(account_id: "A1229ZQJ").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EG20")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Incoming faster payment")
          expect(transaction.created_at).to eql("2023-04-12T10:10:52.000+0000")
          expect(transaction.final_at).to eql("2023-04-12T10:10:52.146+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("PI_FAST")
          expect(transaction.source_id).to eql("P1200AJ9NP")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("4995.28")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a UK internal faster payment" do
        let(:account) { "A1229ZQJ" }
        let(:fixture_name) { "incoming/success_faster_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A1229ZQJ").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EHY4")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Incoming internal faster payment")
          expect(transaction.created_at).to eql("2023-04-12T15:02:28.000+0000")
          expect(transaction.final_at).to eql("2023-04-12T15:02:29.676+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P1200AJBNT")
          expect(transaction.external_reference).to eql("tra_2mWHsnsUHdqA4oA0MiP7up")
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("4995.28")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR payment" do
        let(:account) { "A1216A1Z" }
        let(:fixture_name) { "incoming/success_sepa_transactions" }
        let!(:transaction) { transactions.list(account_id: "A1216A1Z").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EBDW")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Incoming sepa payment")
          expect(transaction.created_at).to eql("2023-04-11T16:16:20.000+0000")
          expect(transaction.final_at).to eql("2023-04-11T16:16:20.916+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("PI_SECT")
          expect(transaction.source_id).to eql("P1200AJ55X")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("19381.22")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR internal payment" do
        let(:account) { "A1216A40" }
        let(:fixture_name) { "incoming/success_sepa_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A1216A40").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EJ1H")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Incoming internal sepa")
          expect(transaction.created_at).to eql("2023-04-12T15:15:07.000+0000")
          expect(transaction.final_at).to eql("2023-04-12T15:15:07.369+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P1200AJBRK")
          expect(transaction.external_reference).to eql("tra_24WBQb650pCE7w4Mz8nMLZ")
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("102.47")
          expect(transaction.available_balance).to be_nil
        end
      end
    end

    context "with outgoing transactions" do
      before do
        stub_request(:get, %r{/accounts/#{account}/transactions}).to_return(
          read_http_response_fixture("transactions/list", fixture_name)
        )
      end

      context "when it is a UK faster payment" do
        let(:account) { "A122CZ7E" }
        let(:fixture_name) { "outgoing/success_faster_transactions" }
        let!(:transaction) { transactions.list(account_id: "A122CZ7E").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006APHM")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Payment to Uk account")
          expect(transaction.created_at).to eql("2023-03-24T11:38:00.000+0000")
          expect(transaction.final_at).to eql("2023-03-24T11:38:01.983+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_FAST")
          expect(transaction.source_id).to eql("P1200AB9X3")
          expect(transaction.external_reference).to eql("tra_6A2UC6aOemcxpBhfpUGVM7")
          expect(transaction.additional_info).to include(:schemeInfo)
          expect(transaction.balance).to eql("49998.86")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a UK internal faster payment" do
        let(:account) { "A120N63Q" }
        let(:fixture_name) { "outgoing/success_faster_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A120N63Q").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EHY3")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Internal Payment from UK account")
          expect(transaction.created_at).to eql("2023-04-12T15:02:28.000+0000")
          expect(transaction.final_at).to eql("2023-04-12T15:02:29.640+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P1200AJBNT")
          expect(transaction.external_reference).to eql("tra_2mWHsnsUHdqA4oA0MiP7up")
          expect(transaction.additional_info).to be_nil
          expect(transaction.balance).to eql("49998.86")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR instant payment" do
        let(:account) { "A122CZ7E" }
        let(:fixture_name) { "outgoing/success_sepa_inst_transactions" }
        let!(:transaction) { transactions.list(account_id: "A122CZ7E").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006FS3Z")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to John: Outgoing payment instant")
          expect(transaction.created_at).to eql("2023-04-19T09:13:47.000+0000")
          expect(transaction.final_at).to eql("2023-04-19T09:13:48.008+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_SEPA_INST")
          expect(transaction.source_id).to eql("P1200AKJK1")
          expect(transaction.external_reference).to eql("tra_16Zo5PPqFndOhIXIQr8w0f")
          expect(transaction.additional_info).to include(
            schemeInfo: hash_including(name: "SEPA_INSTANT")
          )
          expect(transaction.balance).to eql("4995.28")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR regular payment" do
        let(:account) { "A122CZ7E" }
        let(:fixture_name) { "outgoing/success_sepa_regular_transactions" }
        let!(:transaction) { transactions.list(account_id: "A122CZ7E").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12005ZT1K")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to John: Outgoing payment regular")
          expect(transaction.created_at).to eql("2023-02-17T13:10:07.000+0000")
          expect(transaction.final_at).to eql("2023-02-17T13:10:09.529+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_SECT")
          expect(transaction.source_id).to eql("P12006YWZ1")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to be_nil
          expect(transaction.balance).to eql("4995.28")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR internal payment" do
        let(:account) { "A122CZ7E" }
        let(:fixture_name) { "outgoing/success_sepa_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A122CZ7E").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T12006EJ1G")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to To Modulr account: Modulr internal")
          expect(transaction.created_at).to eql("2023-04-12T15:15:07.000+0000")
          expect(transaction.final_at).to eql("2023-04-12T15:15:07.300+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P1200AJBRK")
          expect(transaction.external_reference).to eql("tra_24WBQb650pCE7w4Mz8nMLZ")
          expect(transaction.additional_info).to be_nil
          expect(transaction.balance).to eql("4995.28")
          expect(transaction.available_balance).to be_nil
        end
      end
    end
  end
end
