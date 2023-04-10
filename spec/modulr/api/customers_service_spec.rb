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

  describe "create customer" do
    context "when the params are valid" do
      before do
        stub_request(:post, %r{/customers}).to_return(
          read_http_response_fixture("customers/create", "success")
        )
      end

      let!(:created_customer) do
        customers.create(
          type: "LLC",
          legal_entity: "GB",
          external_reference: "My new customer",
          name: "string",
          company_reg_number: "2018123987165432",
          registered_address: {
            addressLine1: "string",
            addressLine2: "string",
            postTown: "string",
            postCode: "string",
            country: "GB",
            countrySubDivision: "string",
          },
          trading_address: {
            addressLine1: "string",
            addressLine2: "string",
            postTown: "string",
            postCode: "string",
            country: "GB",
            countrySubDivision: "string",
          },
          industry_code: "string",
          tcs_version: 0,
          expected_monthly_spend: 0,
          associates: [
            {
              type: "DIRECTOR",
              firstName: "string",
              middleName: "string",
              lastName: "string",
              dateOfBirth: "string",
              ownership: 0,
              homeAddress: {
                addressLine1: "string",
                addressLine2: "string",
                postTown: "string",
                postCode: "string",
                country: "GB",
                countrySubDivision: "string",
              },
              applicant: true,
              email: "string",
              phone: "string",
              documentInfo: [
                {
                  path: "string",
                  fileName: "string",
                  uploadedDate: "2017-01-28T01:01:01+0000",
                },
              ],
              additionalIdentifiers: [
                {
                  type: "BSN",
                  value: "string",
                },
              ],
              complianceData: {
                relationship: "string",
              },
            },
          ],
          document_info: [
            {
              path: "string",
              fileName: "string",
              uploadedDate: "2017-01-28T01:01:01+0000",
            },
          ],
          provisional_customer_id: "string",
          customer_trust: {
            trustNature: "BARE_TRUSTS",
          },
          tax_profile: {
            tax_identifier: "string",
          }
        )
      end

      it_behaves_like "builds correct request", {
        method: :post,
        path: %r{/customers},
        body: {
          type: "LLC",
          legalEntity: "GB",
          externalReference: "My new customer",
          name: "string",
          companyRegNumber: "2018123987165432",
          registeredAddress: {
            addressLine1: "string",
            addressLine2: "string",
            postTown: "string",
            postCode: "string",
            country: "GB",
            countrySubDivision: "string",
          },
          tradingAddress: {
            addressLine1: "string",
            addressLine2: "string",
            postTown: "string",
            postCode: "string",
            country: "GB",
            countrySubDivision: "string",
          },
          industryCode: "string",
          tcsVersion: 0,
          expectedMonthlySpend: 0,
          associates: [
            {
              type: "DIRECTOR",
              firstName: "string",
              middleName: "string",
              lastName: "string",
              dateOfBirth: "string",
              ownership: 0,
              homeAddress: {
                addressLine1: "string",
                addressLine2: "string",
                postTown: "string",
                postCode: "string",
                country: "GB",
                countrySubDivision: "string",
              },
              applicant: true,
              email: "string",
              phone: "string",
              documentInfo: [
                {
                  path: "string",
                  fileName: "string",
                  uploadedDate: "2017-01-28T01:01:01+0000",
                },
              ],
              additionalIdentifiers: [
                {
                  type: "BSN",
                  value: "string",
                },
              ],
              complianceData: {
                relationship: "string",
              },
            },
          ],
          documentInfo: [
            {
              path: "string",
              fileName: "string",
              uploadedDate: "2017-01-28T01:01:01+0000",
            },
          ],
          provisionalCustomerId: "string",
          customerTrust: {
            trustNature: "BARE_TRUSTS",
          },
          taxProfile: {
            tax_identifier: "string",
          },
        },
      }

      it "returns created customer" do
        expect(created_customer).to be_a Modulr::Resources::Customers::Customer
        expect(created_customer.external_reference).to eql("My new customer")
      end
    end

    context "when the type is invalid" do
      before do
        stub_request(:post, %r{/customers}).to_return(
          read_http_response_fixture("customers/create", "invalid_type")
        )
      end

      let!(:params) do
        {
          type: "UNKNOWN",
          legal_entity: "GB",
        }
      end

      it "raise the correct error" do
        expect { customers.create(**params) }.to raise_error Modulr::RequestError
      end
    end

    context "when the legal entity is invalid" do
      before do
        stub_request(:post, %r{/customers}).to_return(
          read_http_response_fixture("customers/create", "invalid_legal_entity")
        )
      end

      let!(:params) do
        {
          type: "LLC",
          legal_entity: "UNKNOWN",
        }
      end

      it "raise the correct error" do
        expect { customers.create(**params) }.to raise_error Modulr::RequestError
      end
    end
  end
end
