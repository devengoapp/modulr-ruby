# frozen_string_literal: true

RSpec.describe Modulr::API::PaymentsService, :unit, type: :client do
  subject(:payments) { described_class.new(client) }

  let(:client) { instance_double(Modulr::Client) }
  let(:response) { Struct.new(:body, keyword_init: true) }
  let(:modulr_response) { response.new(body: fixture_response) }
  let(:options) { {} }
  let(:fixture_response) do
    YAML.safe_load(File.open("spec/fixtures/payments/201_payment_create.json"))
  end
  let!(:payment) do
    allow(client).to receive(:post).and_return(modulr_response).once

    payments.create(
      account_id: "account_id",
      currency: "currency",
      amount: "amount",
      destination: {
        type: "destination_type",
        iban: "destination_iban",
        name: "destination_name",
      },
      reference: "reference",
      options: options
    )
  end

  it "creates the payment" do
    expect(payment).to be_a Modulr::Resources::Payments::Payment
  end

  it "calls to the endpoint" do
    expect(client).to have_received(:post).once do |param, data|
      expect(param).to eq "/payments"
      expect(data).to match({
        sourceAccountId: "account_id",
        currency: "currency",
        amount: "amount",
        reference: "reference",
        destination: {
          type: "destination_type",
          iban: "destination_iban",
          name: "destination_name",
        },
      })
    end
  end

  context "with a external reference option" do
    let(:options) { { external_reference: "external_reference" } }

    it "sends the external reference param" do
      expect(client).to have_received(:post).once do |param, data|
        expect(param).to eq "/payments"
        expect(data).to match({
          sourceAccountId: "account_id",
          currency: "currency",
          amount: "amount",
          reference: "reference",
          externalReference: "external_reference",
          destination: {
            type: "destination_type",
            iban: "destination_iban",
            name: "destination_name",
          },
        })
      end
    end
  end
end
