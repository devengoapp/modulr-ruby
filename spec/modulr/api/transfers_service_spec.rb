# frozen_string_literal: true

RSpec.describe Modulr::API::TransfersService, :unit, type: :client do
  subject(:transfers) { described_class.new(client) }

  let(:client) { instance_double(Modulr::Client) }
  let(:response) { Struct.new(:body, keyword_init: true) }
  let(:modulr_response) { response.new(body: { data: fixture_response }) }
  let(:options) { {} }
  let(:fixture_response) do
    YAML.safe_load(File.open("spec/fixtures/transfers/201_transfer_create.json"))
  end
  let!(:transfer) do
    allow(client).to receive(:post).and_return(modulr_response).once

    transfers.create(
      account_id: "account_id",
      currency: "currency",
      amount: "amount",
      destination_type: "destination_type",
      destination_iban: "destination_iban",
      destination_name: "destination_name",
      reference: "reference",
      options: options
    )
  end

  it "creates the transfer" do
    expect(transfer).to be_a Modulr::Resources::Transfers::Transfer
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
