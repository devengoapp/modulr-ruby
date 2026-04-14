# frozen_string_literal: true

RSpec.shared_examples "builds correct request" do |params|
  let(:default_headers) do
    {
      "Authorization" => "api_key",
      "Content-Type" => "application/json",
    }
  end
  let(:method) { params[:method].to_sym || :get }
  let(:path) { params[:path] || nil }
  let(:headers) { params[:headers] || default_headers }
  let(:query) { params[:query] || nil }

  it "builds correct request" do
    expectation = { headers: headers, query: query }
    expectation[:body] = params[:body] if params.key?(:body)
    expect(WebMock).to have_requested(method, path).with(**expectation)
  end
end
