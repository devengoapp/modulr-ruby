# frozen_string_literal: true

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
    context "when the id is valid" do
      before do
        stub_request(:get, %r{/payments}).to_return(
          read_http_response_fixture("payments/find", "success")
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
        expect(found_payment.id).to eql("P210FFT5AW")
        expect(found_payment.status).to eql("PROCESSED")
        expect(found_payment.created_at).to eql("2023-01-20T09:30:33.033+0000")
        expect(found_payment.reference).to eql("P210FFT5AW")
        expect(found_payment.approval_status).to eql("NOTNEEDED")
        expect(found_payment.details).to be_a Modulr::Resources::Payments::Details
        expect(found_payment.details.source_account_id).to eql("A21BZ2GE")
        expect(found_payment.details.currency).to eql("EUR")
        expect(found_payment.details.amount).to be 0.04
        expect(found_payment.details.reference).to eql("The original ref")
        expect(found_payment.details.destination).to be_a Modulr::Resources::Payments::Destination
        expect(found_payment.details.destination.type).to eql("IBAN")
        expect(found_payment.details.destination.iban).to eql("IE20MODR99035502290413")
        expect(found_payment.details.destination.name).to eql("Aitor García Rey")
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
          expect(exception.errors).not_to be_empty
          expect(exception.errors.select { |error| error[:field] == "fromCreatedDate" }).not_to be_empty
        end)
      end
    end
  end
end
