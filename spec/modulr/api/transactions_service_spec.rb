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

      let!(:list) { transactions.list(account_id: "A0000001", credit: true, page: 0, size: 20) }

      it_behaves_like "builds correct request", {
        method: :get,
        path: %r{/accounts/A0000001/transactions},
        query: { credit: "true", page: "0", size: "20" },
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
        let(:account) { "A21CM4HE" }
        let(:fixture_name) { "incoming/responses/success_faster_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21CM4HE").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RU61D7")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Incoming faster payment")
          expect(transaction.created_at).to eql("2023-03-17T08:18:10.000+0000")
          expect(transaction.final_at).to eql("2023-03-17T08:18:55.851+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("PI_FAST")
          expect(transaction.source_id).to eql("P210H4GX3H")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("0.01")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a UK internal faster payment" do
        let(:account) { "A1229ZQJ" }
        let(:fixture_name) { "incoming/responses/success_faster_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A1229ZQJ").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RHN1R3")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Faster internal payment")
          expect(transaction.created_at).to eql("2023-03-10T18:20:13.000+0000")
          expect(transaction.final_at).to eql("2023-03-10T18:20:13.298+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P210GY2JDJ")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("0.01")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR instant payment" do
        let(:account) { "A21DC314" }
        let(:fixture_name) { "incoming/responses/success_sepa_inst_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21DC314").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RVSTQM")
          expect(transaction.amount).to be(2.0)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Incoming sepa instant payment")
          expect(transaction.created_at).to eql("2023-03-20T09:16:51.000+0000")
          expect(transaction.final_at).to eql("2023-03-20T09:16:53.702+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("PI_SEPA_INST")
          expect(transaction.source_id).to eql("P210H5KU1B")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("2.01")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR regular payment" do
        let(:account) { "A21E68Z1" }
        let(:fixture_name) { "incoming/responses/success_sepa_regular_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21E68Z1").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210T3YK09")
          expect(transaction.amount).to be(40_000.0)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Incoming sepa regular payment")
          expect(transaction.created_at).to eql("2023-06-20T07:16:11.000+0000")
          expect(transaction.final_at).to eql("2023-06-20T07:16:35.708+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("PI_SECT")
          expect(transaction.source_id).to eql("P210J30EGV")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("201003.97")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR internal payment" do
        let(:account) { "A21C64X7" }
        let(:fixture_name) { "incoming/responses/success_sepa_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21C64X7").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RHA656")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment from Devengo: Sepa internal payment")
          expect(transaction.created_at).to eql("2023-03-10T15:30:28.000+0000")
          expect(transaction.final_at).to eql("2023-03-10T15:30:28.448+0000")
          expect(transaction.credit).to be(true)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P210GXV1UW")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            payer: hash_including(:name, :identifier)
          )
          expect(transaction.balance).to eql("0.07")
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
        let(:account) { "A21CM4HE" }
        let(:fixture_name) { "outgoing/responses/success_faster_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21CM4HE").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RU91P4")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Payment to Jonh: Outgoing faster payment")
          expect(transaction.created_at).to eql("2023-03-17T09:20:55.000+0000")
          expect(transaction.final_at).to eql("2023-03-17T09:20:56.418+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_FAST")
          expect(transaction.source_id).to eql("P210H4JZZ7")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(:schemeInfo)
          expect(transaction.balance).to eql("0.01")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a UK internal faster payment" do
        let(:account) { "A21BZ2GY" }
        let(:fixture_name) { "outgoing/responses/success_faster_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21BZ2GY").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RHN1R1")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("GBP")
          expect(transaction.description).to eql("Payment to Devengo: Faster outgoing internal payment")
          expect(transaction.created_at).to eql("2023-03-10T18:20:13.000+0000")
          expect(transaction.final_at).to eql("2023-03-10T18:20:13.244+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P210GY2JDJ")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to be_nil
          expect(transaction.balance).to eql("4.10")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR instant payment" do
        let(:account) { "A21E68ZZ" }
        let(:fixture_name) { "outgoing/responses/success_sepa_inst_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21E68ZZ").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210SY412P")
          expect(transaction.amount).to be(148.0)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to John: Outgoing sepa instant payment")
          expect(transaction.created_at).to eql("2023-06-06T07:24:21.000+0000")
          expect(transaction.final_at).to eql("2023-06-06T07:24:23.531+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_SEPA_INST")
          expect(transaction.source_id).to eql("P210HYHNCT")
          expect(transaction.external_reference).to eql("tra_cPz0LfwBZ41oYzITQDW1Z")
          expect(transaction.additional_info).to include(
            schemeInfo: hash_including(name: "SEPA_INSTANT")
          )
          expect(transaction.balance).to eql("200823.97")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR regular payment" do
        let(:account) { "A122CZ7E" }
        let(:fixture_name) { "outgoing/responses/success_sepa_regular_transactions" }
        let!(:transaction) { transactions.list(account_id: "A122CZ7E").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210T4BENK")
          expect(transaction.amount).to be(950.0)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to John: Outgoing sepa regular payment")
          expect(transaction.created_at).to eql("2023-06-20T17:53:33.000+0000")
          expect(transaction.final_at).to eql("2023-06-21T05:51:48.647+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("PO_SECT")
          expect(transaction.source_id).to eql("P210J382BE")
          expect(transaction.external_reference).to eql("tra-7ThiITm9hlKhY6YCrDXVFL")
          expect(transaction.additional_info).to include(
            schemeInfo: hash_including(name: "SEPA_CREDIT_TRANSFER")
          )
          expect(transaction.balance).to eql("200823.97")
          expect(transaction.available_balance).to be_nil
        end
      end

      context "when it is a EUR internal payment" do
        let(:account) { "A21BZ2GF" }
        let(:fixture_name) { "outgoing/responses/success_sepa_internal_transactions" }
        let!(:transaction) { transactions.list(account_id: "A21BZ2GF").first }

        it "returns correct transaction payload" do
          expect(transaction).to be_a Modulr::Resources::Transactions::Transaction
          expect(transaction.id).to eql("T210RHA653")
          expect(transaction.amount).to be(0.01)
          expect(transaction.currency).to eql("EUR")
          expect(transaction.description).to eql("Payment to Devengo: Sepa outgoing internal payment")
          expect(transaction.created_at).to eql("2023-03-10T15:30:28.000+0000")
          expect(transaction.final_at).to eql("2023-03-10T15:30:28.407+0000")
          expect(transaction.credit).to be(false)
          expect(transaction.type).to eql("INT_INTERC")
          expect(transaction.source_id).to eql("P210GXV1UW")
          expect(transaction.external_reference).to be_nil
          expect(transaction.additional_info).to include(
            schemeInfo: {}
          )
          expect(transaction.balance).to eql("0.58")
          expect(transaction.available_balance).to be_nil
        end
      end
    end
  end
end
