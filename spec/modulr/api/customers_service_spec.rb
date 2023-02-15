# frozen_string_literal: true

RSpec.describe Modulr::API::CustomersService, :unit, type: :client do
  subject(:customers) { described_class.new(initialize_client) }

  describe "find customer" do
    context "when the id is valid" do
      before do
        stub_request(:get, %r{/customers/C2188C26}).to_return(
          read_http_response_fixture("customers/find", "success")
        )
      end

      let!(:found_customer) do
        customers.find(id: "C2188C26")
      end

      it_behaves_like "builds correct request", {
        method: :get,
        path: %r{/customers/C2188C26},
      }

      it "returns the account" do
        expect(found_customer).to be_a Modulr::Resources::Customers::Customer
        expect(found_customer.id).to eql("C2188C26")
        expect(found_customer.name).to eql("Devengo")
        expect(found_customer.type).to eql("PLC")
        expect(found_customer.status).to eql("ACTIVE")
        expect(found_customer.taxid).to eql("B42722025")
        expect(found_customer.type).to eql("PLC")
        expect(found_customer.legal_entity).to eql("IE")
      end
    end

    context "when id is invalid" do
      before do
        stub_request(:get, %r{/customers/CCC}).to_return(
          read_http_response_fixture("customers/find", "invalid_id")
        )
      end

      it "raise the correct error" do
        expect { customers.find(id: "CCC") }.to raise_error Modulr::RequestError
      end
    end

    context "when id is not found" do
      before do
        stub_request(:get, %r{/customers/C9999C99}).to_return(
          read_http_response_fixture("customers/find", "not_found")
        )
      end

      it "raise the correct error" do
        expect { customers.find(id: "C9999C99") }.to raise_error Modulr::NotFoundError
      end
    end
  end
end
