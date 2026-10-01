# frozen_string_literal: true

RSpec.describe Modulr::Resources::Payments::Payment, :unit, type: :client do
  subject(:payment) { described_class.new(nil, attributes) }

  let(:credit_transfer_key) { :fitoFICstmrCdtTrf }
  let(:doc_type) { "FFCCTRNS" }
  let(:transaction) { { pmtId: { endToEndId: "E2E-1" } } }
  let(:transactions) { doc_type == "FFCCTRNS" ? [transaction] : transaction }
  let(:attributes) do
    {
      details: {
        type: "PI_SECT",
        payer: { name: "Payer", identifier: { type: "IBAN", iban: "ES0000000000000000000000" } },
        payee: { name: "Payee", identifier: { type: "IBAN", iban: "ES1111111111111111111111" } },
        details: {
          payload: {
            docs: {
              doc: {
                header: { type: doc_type },
                doc_type.downcase.to_sym => {
                  document: {
                    credit_transfer_key => { cdtTrfTxInf: transactions },
                  },
                },
              },
            },
          },
        },
      },
    }
  end

  describe "#end_to_end_id" do
    it "reads a SEPA regular end to end id from the legacy key" do
      expect(payment.end_to_end_id).to eq("E2E-1")
    end

    context "when the SEPA regular payload uses FIToFICstmrCdtTrf" do
      let(:credit_transfer_key) { :FIToFICstmrCdtTrf }

      it "reads the end to end id" do
        expect(payment.end_to_end_id).to eq("E2E-1")
      end
    end

    context "when the SEPA instant payload uses the legacy key" do
      let(:doc_type) { "IFCCTRNS" }

      it "reads the end to end id" do
        expect(payment.end_to_end_id).to eq("E2E-1")
      end
    end

    context "when the SEPA instant payload uses FIToFICstmrCdtTrf" do
      let(:doc_type) { "IFCCTRNS" }
      let(:credit_transfer_key) { :FIToFICstmrCdtTrf }

      it "reads the end to end id" do
        expect(payment.end_to_end_id).to eq("E2E-1")
      end
    end
  end
end
