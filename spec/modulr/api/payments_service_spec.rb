# frozen_string_literal: true

RSpec.describe Modulr::API::PaymentsService, :unit, type: :client do
  subject(:payments) { described_class.new(initialize_client) }

  describe "create payment" do
    context "when the params are valid" do
      before do
        stub_request(:post, %r{/payments}).to_return(
          read_http_response_fixture("payments/create", "success")
        )
      end

      let!(:created_payment) do
        payments.create(
          account_id: "A21BZ2GE",
          currency: "EUR",
          amount: "0.02",
          destination: {
            type: "IBAN",
            iban: "ES6015632626303264517956",
            name: "Aitor García Rey",
          },
          reference: "The reference"
        )
      end

      it_behaves_like "builds correct request", {
        method: :post,
        path: %r{/payments},
        body: {
          sourceAccountId: "A21BZ2GE",
          currency: "EUR",
          amount: "0.02",
          destination: {
            type: "IBAN",
            iban: "ES6015632626303264517956",
            name: "Aitor García Rey",
          },
          reference: "The reference",
        },
      }

      it "returns created payment" do
        expect(created_payment).to be_a Modulr::Resources::Payments::Payment
        expect(created_payment.id).to eql("P210FFRUVT")
        expect(created_payment.status).to eql("VALIDATED")
        expect(created_payment.reference).to eql("P210FFRUVT")
        expect(created_payment.external_reference).to eql("The external reference")
        expect(created_payment.approval_status).to eql("NOTNEEDED")
      end
    end
  end

  describe "find payment" do
    context "with unexisting IDs" do
      before do
        stub_request(:get, %r{/payments})
          .with(query: hash_including({ "id" => "P99C99X9" }))
          .to_return(
            read_http_response_fixture("payments/find", "not_found")
          )
      end

      it "raise the correct error" do
        expect { payments.find(id: "P99C99X9") }.to raise_error Modulr::NotFoundError
      end
    end

    context "with incoming payments" do
      context "when it is a UK faster payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210H4GX3H" }))
            .to_return(
              read_http_response_fixture("payments/find/incoming", "success_faster_payments")
            )
        end

        let!(:fps_payment) do
          payments.find(id: "P210H4GX3H")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(fps_payment).to be_a Modulr::Resources::Payments::Payment
          expect(fps_payment.id).to eql("P210H4GX3H")
          expect(fps_payment.status).to eql("PROCESSED")
          expect(fps_payment.created_at).to eql("2023-03-17T08:18:10.010+0000")
          expect(fps_payment.reference).to eql("P210H4GX3H")
          expect(fps_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::General
          expect(fps_payment.details.created_at).to eql("2023-03-17T08:18:10.569+00:00")
          expect(fps_payment.details.posted_at).to eql("2023-03-17T08:18:10.569+00:00")
          expect(fps_payment.details.type).to eql("PI_FAST")
          expect(fps_payment.details.description).to eql("Payment from Aitor Garcia Rey: Aitor from Wise")
          expect(fps_payment.details.original_reference).to eql("Aitor from Wise")
          expect(fps_payment.details.currency).to eql("GBP")
          expect(fps_payment.details.amount).to be 0.01
          expect(fps_payment.details.account_number).to eql("A21CM4HA")
          expect(fps_payment.details.scheme_id).to eql("TW00000005322175031020230317826231470")
          expect(fps_payment.details.raw_details.keys).to include(:fpsTransaction)
          expect(fps_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(fps_payment.details.payer.name).to eql("Aitor Garcia Rey")
          expect(fps_payment.details.payer.identifier.type).to eql("SCAN")
          expect(fps_payment.details.payer.identifier.sort_code).to eql("TRWIBEBB")
          expect(fps_payment.details.payer.identifier.account_number).to eql("P12642236")
          expect(fps_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(fps_payment.details.payee.name).to eql("Devengo SL")
          expect(fps_payment.details.payee.identifier.type).to eql("SCAN")
          expect(fps_payment.details.payee.identifier.sort_code).to eql("040392")
          expect(fps_payment.details.payee.identifier.account_number).to eql("00631973")
        end
      end

      context "when it is SCT-INST payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210H5KU1B" }))
            .to_return(
              read_http_response_fixture("payments/find/incoming", "success_sepa_inst")
            )
        end

        let!(:sct_inst_payment) do
          payments.find(id: "P210H5KU1B")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(sct_inst_payment).to be_a Modulr::Resources::Payments::Payment
          expect(sct_inst_payment.id).to eql("P210H5KU1B")
          expect(sct_inst_payment.status).to eql("PROCESSED")
          expect(sct_inst_payment.created_at).to eql("2023-03-20T09:16:53.053+0000")
          expect(sct_inst_payment.reference).to eql("P210H5KU1B")
          expect(sct_inst_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::General
          expect(sct_inst_payment.details.created_at).to eql("2023-03-20T09:16:53.503+00:00")
          expect(sct_inst_payment.details.posted_at).to eql("2023-03-20T09:16:51.000+00:00")
          expect(sct_inst_payment.details.type).to eql("PI_SEPA_INST")
          expect(sct_inst_payment.details.description).to eql("Payment from Aitor Garcia Rey: Enviada desde N26")
          expect(sct_inst_payment.details.original_reference).to eql("Enviada desde N26")
          expect(sct_inst_payment.details.currency).to eql("EUR")
          expect(sct_inst_payment.details.amount).to be 2.00
          expect(sct_inst_payment.details.account_number).to eql("A21DC313")
          expect(sct_inst_payment.details.scheme_id).to eql("SI23032029385314-O-f9ffc22bc62e300788f538eafd75db28")
          expect(sct_inst_payment.details.raw_details.keys).to include(:type, :payload)
          expect(sct_inst_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_inst_payment.details.payer.name).to eql("Aitor Garcia Rey")
          expect(sct_inst_payment.details.payer.identifier.type).to eql("IBAN")
          expect(sct_inst_payment.details.payer.identifier.iban).to eql("ES6015632626303264517956")
          expect(sct_inst_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_inst_payment.details.payee.name).to eql("AGR tests in Devengo Modulr")
          expect(sct_inst_payment.details.payee.identifier.type).to eql("IBAN")
          expect(sct_inst_payment.details.payee.identifier.iban).to eql("IE21MODR99035502154595")
        end
      end
    end

    context "with outgoing payments" do
      context "when the id is valid" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210FFT5AW" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_iban")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210FFT5AW")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the account" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.id).to eql("P210G2CY0N")
          expect(found_payment.status).to eql("PROCESSED")
          expect(found_payment.created_at).to eql("2023-02-09T18:19:47.047+0000")
          expect(found_payment.reference).to eql("P210G2CY0N")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details).to be_a Modulr::Resources::Payments::Details::Outgoing::General
          expect(found_payment.details.source_account_id).to eql("A21BZ2GE")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 0.01
          expect(found_payment.details.reference).to eql("The reference")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.type).to eql("IBAN")
          expect(found_payment.details.destination.iban).to eql("ES6015632626303264517956")
          expect(found_payment.details.destination.name).to eql("Aitor García Rey")
        end
      end
    end
  end

  describe "list payment" do
    context "when params are valid" do
      before do
        stub_request(:get, %r{/payments}).to_return(
          read_http_response_fixture("payments/list", "success")
        )
      end

      let!(:payment_list) do
        payments.list(from: Date.today - 1, type: "PAYOUT")
      end

      it "returns a collection of payments" do
        expect(payment_list).to be_a Modulr::Resources::Payments::Collection
        expect(payment_list.count).to be(4)
      end
    end

    context "when from date is too old" do
      before do
        stub_request(:get, %r{/payments}).to_return(
          read_http_response_fixture("payments/list", "from_too_old")
        )
      end

      it "raise the correct error" do
        expect { payments.list(from: Date.today - 300) }.to(raise_error do |exception|
          expect(exception).to be_a(Modulr::RequestError)
          expect(exception.errors).not_to be_empty
          expect(exception.errors.select { |error| error[:field] == "fromCreatedDate" }).not_to be_empty
        end)
      end
    end
  end
end
