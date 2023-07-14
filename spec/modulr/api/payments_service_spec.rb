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
          account_id: "A21E68ZZ",
          currency: "EUR",
          amount: "148.0",
          destination: {
            type: "IBAN",
            iban: "ES3200810106680006714488",
            name: "John",
          },
          reference: "Outgoing sepa instant payment"
        )
      end

      it_behaves_like "builds correct request", {
        method: :post,
        path: %r{/payments},
        body: {
          sourceAccountId: "A21E68ZZ",
          currency: "EUR",
          amount: "148.0",
          destination: {
            type: "IBAN",
            iban: "ES3200810106680006714488",
            name: "John",
          },
          reference: "Outgoing sepa instant payment",
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
          expect(fps_payment.details.description).to eql("Incoming faster payment")
          expect(fps_payment.details.original_reference).to eql("Incoming faster payment fixture")
          expect(fps_payment.details.currency).to eql("GBP")
          expect(fps_payment.details.amount).to be 0.01
          expect(fps_payment.details.account_number).to eql("A21CM4HE")
          expect(fps_payment.details.scheme_id).to eql("TW00000005322175031020230317826231470")
          expect(fps_payment.details.raw_details.keys).to include(:fpsTransaction)
          expect(fps_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(fps_payment.details.payer.name).to eql("John")
          expect(fps_payment.details.payer.identifier.type).to eql("SCAN")
          expect(fps_payment.details.payer.identifier.sort_code).to eql("TRWIBEBC")
          expect(fps_payment.details.payer.identifier.account_number).to eql("P12642237")
          expect(fps_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(fps_payment.details.payee.name).to eql("Devengo SL")
          expect(fps_payment.details.payee.identifier.type).to eql("SCAN")
          expect(fps_payment.details.payee.identifier.sort_code).to eql("040393")
          expect(fps_payment.details.payee.identifier.account_number).to eql("00631974")
          expect(fps_payment.details.destination.name).to eql("Devengo SL")
          expect(fps_payment.details.destination.identifier.type).to eql("SCAN")
          expect(fps_payment.details.destination.identifier.sort_code).to eql("040393")
          expect(fps_payment.details.destination.identifier.account_number).to eql("00631974")
          expect(fps_payment.end_to_end_id).to eql("Incoming faster payment fixture")
          expect(fps_payment.network).to eql("FPS")
          expect(fps_payment.scheme).to eql("Faster Payments")
          expect(fps_payment.type).to eql("PI_FAST")
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
          expect(sct_inst_payment.details.description).to eql("Incoming sepa instant payment")
          expect(sct_inst_payment.details.original_reference).to eql("Incoming sepa instant payment fixture")
          expect(sct_inst_payment.details.currency).to eql("EUR")
          expect(sct_inst_payment.details.amount).to be 2.00
          expect(sct_inst_payment.details.account_number).to eql("A21DC314")
          expect(sct_inst_payment.details.scheme_id).to eql("SI23032029385314-O-f9ffc22bc62e300788f538eafd75db20")
          expect(sct_inst_payment.details.raw_details.keys).to include(:type, :payload)
          expect(sct_inst_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_inst_payment.details.payer.name).to eql("John")
          expect(sct_inst_payment.details.payer.identifier.type).to eql("IBAN")
          expect(sct_inst_payment.details.payer.identifier.iban).to eql("ES6015632626303264517957")
          expect(sct_inst_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_inst_payment.details.payee.name).to eql("Devengo")
          expect(sct_inst_payment.details.payee.identifier.type).to eql("IBAN")
          expect(sct_inst_payment.details.payee.identifier.iban).to eql("IE21MODR99035502154596")
          expect(sct_inst_payment.details.destination.name).to eql("Devengo")
          expect(sct_inst_payment.details.destination.identifier.type).to eql("IBAN")
          expect(sct_inst_payment.details.destination.identifier.iban).to eql("IE21MODR99035502154596")
          expect(sct_inst_payment.end_to_end_id).to eql "NOTPROVIDED"
          expect(sct_inst_payment.network).to eql("SEPA")
          expect(sct_inst_payment.scheme).to eql("SEPA Instant Credit Transfers")
          expect(sct_inst_payment.type).to eql("PI_SEPA_INST")
        end
      end

      context "when it is SCT-REGULAR payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210J30EGV" }))
            .to_return(
              read_http_response_fixture("payments/find/incoming", "success_sepa_regular")
            )
        end

        let!(:sct_regular_payment) do
          payments.find(id: "P210J30EGV")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(sct_regular_payment).to be_a Modulr::Resources::Payments::Payment
          expect(sct_regular_payment.id).to eql("P210J30EGV")
          expect(sct_regular_payment.status).to eql("PROCESSED")
          expect(sct_regular_payment.created_at).to eql("2023-06-20T07:16:35.035+0000")
          expect(sct_regular_payment.reference).to eql("P210J30EGV")
          expect(sct_regular_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::General
          expect(sct_regular_payment.details.created_at).to eql("2023-06-20T07:16:35.359+00:00")
          expect(sct_regular_payment.details.posted_at).to eql("2023-06-20T07:16:11.000+00:00")
          expect(sct_regular_payment.details.type).to eql("PI_SECT")
          expect(sct_regular_payment.details.description).to eql("Incoming sepa regular payment")
          expect(sct_regular_payment.details.original_reference).to be_nil
          expect(sct_regular_payment.details.currency).to eql("EUR")
          expect(sct_regular_payment.details.amount).to be 40_000.0
          expect(sct_regular_payment.details.account_number).to eql("A21E68Z1")
          expect(sct_regular_payment.details.scheme_id).to eql("S231710057915821-0569660898269800")
          expect(sct_regular_payment.details.raw_details.keys).to include(:type, :payload)
          expect(sct_regular_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_regular_payment.details.payer.name).to eql("Jonh")
          expect(sct_regular_payment.details.payer.identifier.type).to eql("IBAN")
          expect(sct_regular_payment.details.payer.identifier.iban).to eql("ES2400810361440001700370")
          expect(sct_regular_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(sct_regular_payment.details.payee.name).to eql("Devengo")
          expect(sct_regular_payment.details.payee.identifier.type).to eql("IBAN")
          expect(sct_regular_payment.details.payee.identifier.iban).to eql("IE02MODR99035502304318")
          expect(sct_regular_payment.end_to_end_id).to eql("NOTPROVIDED")
          expect(sct_regular_payment.network).to eql("SEPA")
          expect(sct_regular_payment.scheme).to eql("SEPA Credit Transfers")
          expect(sct_regular_payment.type).to eql("PI_SECT")
        end
      end

      context "when it is an FST INTERNAL type payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210GY2JDJ" }))
            .to_return(
              read_http_response_fixture("payments/find/incoming", "success_faster_internal_payments")
            )
        end

        let!(:fst_internal_incoming_payment) do
          payments.find(id: "P210GY2JDJ")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(fst_internal_incoming_payment).to be_a Modulr::Resources::Payments::Payment
          expect(fst_internal_incoming_payment.id).to eql("P210GY2JDJ")
          expect(fst_internal_incoming_payment.status).to eql("PROCESSED")
          expect(fst_internal_incoming_payment.created_at).to eql("2023-03-10T18:20:12.012+0000")
          expect(fst_internal_incoming_payment.reference).to eql("P210GY2JDJ")
          expect(fst_internal_incoming_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::Internal
          expect(fst_internal_incoming_payment.details.currency).to eql("GBP")
          expect(fst_internal_incoming_payment.details.amount).to be 0.01
          expect(fst_internal_incoming_payment.details.source_account_id).to eql("A21BZ2GY")
          expect(fst_internal_incoming_payment.details.reference).to eql("Faster internal payment")
          expect(fst_internal_incoming_payment.network).to eql("INTERNAL")
          expect(fst_internal_incoming_payment.scheme).to eql("INTERNAL")
          expect(fst_internal_incoming_payment.type).to eql("INT_INTERC")
        end
      end

      context "when it is an SEPA INTERNAL type payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210GXV1UW" }))
            .to_return(
              read_http_response_fixture("payments/find/incoming", "success_sepa_internal_payments")
            )
        end

        let!(:sepa_internal_incoming_payment) do
          payments.find(id: "P210GXV1UW")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(sepa_internal_incoming_payment).to be_a Modulr::Resources::Payments::Payment
          expect(sepa_internal_incoming_payment.id).to eql("P210GXV1UW")
          expect(sepa_internal_incoming_payment.status).to eql("PROCESSED")
          expect(sepa_internal_incoming_payment.created_at).to eql("2023-03-10T15:30:27.027+0000")
          expect(sepa_internal_incoming_payment.reference).to eql("P210GXV1UW")
          expect(sepa_internal_incoming_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::Internal
          expect(sepa_internal_incoming_payment.details.currency).to eql("EUR")
          expect(sepa_internal_incoming_payment.details.amount).to be 0.01
          expect(sepa_internal_incoming_payment.details.source_account_id).to eql("A21BZ2GF")
          expect(sepa_internal_incoming_payment.details.reference).to eql("Sepa internal payment")
          expect(sepa_internal_incoming_payment.network).to eql("INTERNAL")
          expect(sepa_internal_incoming_payment.scheme).to eql("INTERNAL")
          expect(sepa_internal_incoming_payment.type).to eql("INT_INTERC")
        end
      end
    end

    context "with outgoing payments" do
      context "when it is a UK faster payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210H4JZZ7" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_faster_payments")
            )
        end

        let!(:fps_payment) do
          payments.find(id: "P210H4JZZ7")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(fps_payment).to be_a Modulr::Resources::Payments::Payment
          expect(fps_payment.id).to eql("P210H4JZZ7")
          expect(fps_payment.status).to eql("PROCESSED")
          expect(fps_payment.created_at).to eql("2023-03-17T09:20:44.044+0000")
          expect(fps_payment.reference).to eql("P210H4JZZ7")
          expect(fps_payment.approval_status).to eql("NOTNEEDED")
          expect(fps_payment.details).to be_a Modulr::Resources::Payments::Details::Outgoing::General
          expect(fps_payment.details.source_account_id).to eql("A21CM4HE")
          expect(fps_payment.details.currency).to eql("GBP")
          expect(fps_payment.details.amount).to be 0.01
          expect(fps_payment.details.reference).to eql("Outgoing faster payment")
          expect(fps_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(fps_payment.details.destination.identifier.type).to eql("SCAN")
          expect(fps_payment.details.destination.identifier.account_number).to eql("79433112")
          expect(fps_payment.details.destination.identifier.sort_code).to eql("231471")
          expect(fps_payment.details.destination.name).to eql("Jonh")
          expect(fps_payment.network).to eql("FPS")
          expect(fps_payment.scheme).to eql("Faster Payments")
          expect(fps_payment.type).to eql("PO_FAST")
        end
      end

      context "when it is SCT-INST payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210HYHNCT" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_sepa_inst")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210HYHNCT")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.message).to be_empty
          expect(found_payment.id).to eql("P210HYHNCT")
          expect(found_payment.status).to eql("PROCESSED")
          expect(found_payment.created_at).to eql("2023-06-06T07:24:17.017+0000")
          expect(found_payment.reference).to eql("P210HYHNCT")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details).to be_a Modulr::Resources::Payments::Details::Outgoing::General
          expect(found_payment.details.source_account_id).to eql("A21E68ZZ")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 148.0
          expect(found_payment.details.reference).to eql("Outgoing sepa instant payment")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.identifier.type).to eql("IBAN")
          expect(found_payment.details.destination.identifier.iban).to eql("ES3200810106680006714488")
          expect(found_payment.details.destination.name).to eql("John")
          expect(found_payment.network).to eql("SEPA")
          expect(found_payment.scheme).to eql("SEPA Instant Credit Transfers")
          expect(found_payment.type).to eql("PO_SEPA_INST")
        end
      end

      context "when it is SCT-REGULAR payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210J382BE" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_sepa_regular")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210J382BE")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.message).to be_empty
          expect(found_payment.id).to eql("P210J382BE")
          expect(found_payment.status).to eql("PROCESSED")
          expect(found_payment.created_at).to eql("2023-06-20T17:53:28.028+0000")
          expect(found_payment.reference).to eql("P210J382BE")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details).to be_a Modulr::Resources::Payments::Details::Outgoing::General
          expect(found_payment.details.source_account_id).to eql("A21E68ZZ")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 950.0
          expect(found_payment.details.reference).to eql("Outgoing sepa regular payment")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.identifier.type).to eql("IBAN")
          expect(found_payment.details.destination.identifier.iban).to eql("ES0314910001252016488527")
          expect(found_payment.details.destination.name).to eql("John")
          expect(found_payment.external_reference).to eql("tra-7ThiITm9hlKhY6YCrDXVFL")
          expect(found_payment.network).to eql("SEPA")
          expect(found_payment.scheme).to eql("SEPA Credit Transfers")
          expect(found_payment.type).to eql("PO_SECT")
        end
      end

      context "when it is FST INTERNAL payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210GY2JDJ" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_faster_internal_payments")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210GY2JDJ")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.message).to be_empty
          expect(found_payment.id).to eql("P210GY2JDJ")
          expect(found_payment.status).to eql("PROCESSED")
          expect(found_payment.created_at).to eql("2023-03-10T18:20:12.012+0000")
          expect(found_payment.reference).to eql("P210GY2JDJ")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details.source_account_id).to eql("A21BZ2GY")
          expect(found_payment.details.currency).to eql("GBP")
          expect(found_payment.details.amount).to be 0.01
          expect(found_payment.details.reference).to eql("Faster outgoing internal payment")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.identifier.type).to eql("ACCOUNT")
          expect(found_payment.details.destination.identifier.id).to eql("A21CM4HE")
          expect(found_payment.network).to eql("INTERNAL")
          expect(found_payment.scheme).to eql("INTERNAL")
          expect(found_payment.type).to eql("INT_INTERC")
        end
      end

      context "when it is SEPA INTERNAL payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210GXV1UW" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_sepa_internal_payments")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210GXV1UW")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.message).to be_empty
          expect(found_payment.id).to eql("P210GXV1UW")
          expect(found_payment.status).to eql("PROCESSED")
          expect(found_payment.created_at).to eql("2023-03-10T15:30:27.027+0000")
          expect(found_payment.reference).to eql("P210GXV1UW")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details.source_account_id).to eql("A21BZ2GF")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 0.01
          expect(found_payment.details.reference).to eql("Sepa outgoing internal payment")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.identifier.type).to eql("ACCOUNT")
          expect(found_payment.details.destination.identifier.id).to eql("A21C64X7")
          expect(found_payment.network).to eql("INTERNAL")
          expect(found_payment.scheme).to eql("INTERNAL")
          expect(found_payment.type).to eql("INT_INTERC")
        end
      end

      context "when it is SEPA REVERSED payment" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210GXV1UW" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "success_sepa_reversed_payments")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210GXV1UW")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment.created_at).to eql("2023-03-10T15:30:27.027+0000")
          expect(found_payment.reference).to eql("P210GXV1UW")
          expect(found_payment.details).to be_a Modulr::Resources::Payments::Details::Incoming::General
          expect(found_payment.details.created_at).to eql("2023-03-10T15:30:27.027+0000")
          expect(found_payment.details.posted_at).to eql("2023-03-10T15:30:27.028+0000")
          expect(found_payment.details.type).to eql("PO_REV")
          expect(found_payment.details.description).to eql("Return outgoing payment")
          expect(found_payment.details.original_reference).to eql("Devengo")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 1.0
          expect(found_payment.details.account_number).to eql("A21E68ZZ")
          expect(found_payment.details.scheme_id).to eql("S231950059016337-O231951454397512")
          expect(found_payment.details.raw_details.keys).to include(:type, :payload)
          expect(found_payment.details.payer).to be_a Modulr::Resources::Payments::Counterparty
          expect(found_payment.details.payer.name).to eql("John")
          expect(found_payment.details.payer.identifier.type).to eql("IBAN")
          expect(found_payment.details.payer.identifier.iban).to eql("ES3200810106680006714488")
          expect(found_payment.details.payee).to be_a Modulr::Resources::Payments::Counterparty
          expect(found_payment.details.payee.name).to eql("Devengo SL")
          expect(found_payment.details.payee.identifier.type).to eql("IBAN")
          expect(found_payment.details.payee.identifier.iban).to eql("ES2914653111661392648933")
          expect(found_payment.details.payee.identifier.bic).to eql("MODRIE22XXX")
          expect(found_payment.details.destination.name).to eql("Devengo SL")
          expect(found_payment.details.destination.identifier.type).to eql("IBAN")
          expect(found_payment.details.destination.identifier.iban).to eql("ES2914653111661392648933")
          expect(found_payment.details.destination.identifier.bic).to eql("MODRIE22XXX")
          expect(found_payment.end_to_end_id).to be_nil
          expect(found_payment.network).to eql("SEPA")
          expect(found_payment.scheme).to eql("SEPA Credit Transfers")
          expect(found_payment.type).to eql("PO_REV")
        end
      end

      context "when payment was not validated" do
        before do
          stub_request(:get, %r{/payments})
            .with(query: hash_including({ "id" => "P210HYHNCT" }))
            .to_return(
              read_http_response_fixture("payments/find/outgoing", "failed_sepa_payment")
            )
        end

        let!(:found_payment) do
          payments.find(id: "P210HYHNCT")
        end

        it_behaves_like "builds correct request", {
          method: :get,
          path: %r{/payments},
        }

        it "returns the payment" do
          expect(found_payment).to be_a Modulr::Resources::Payments::Payment
          expect(found_payment.message).to eql("Beneficiary Account Blocked. Please review beneficiary information.")
          expect(found_payment.id).to eql("P210HYHNCT")
          expect(found_payment.status).to eql("ER_INVALID")
          expect(found_payment.created_at).to eql("2023-04-14T11:36:03.003+0000")
          expect(found_payment.reference).to eql("P1200AJQPQ")
          expect(found_payment.approval_status).to eql("NOTNEEDED")
          expect(found_payment.details).to be_a Modulr::Resources::Payments::Details::Outgoing::General
          expect(found_payment.details.source_account_id).to eql("A21E68ZZ")
          expect(found_payment.details.currency).to eql("EUR")
          expect(found_payment.details.amount).to be 0.01
          expect(found_payment.details.reference).to eql("From Modulr account")
          expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
          expect(found_payment.details.destination.identifier.type).to eql("IBAN")
          expect(found_payment.details.destination.identifier.iban).to eql("ES2914653111661392648933")
          expect(found_payment.details.destination.name).to eql("John")
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
