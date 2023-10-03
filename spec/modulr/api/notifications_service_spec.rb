# frozen_string_literal: true

RSpec.describe Modulr::API::NotificationsService, :unit, type: :client do
  subject(:notifications) { described_class.new(initialize_client) }

  describe "create notification" do
    context "when the params are valid" do
      before do
        stub_request(:post, %r{/customers/C2188C26/notifications}).to_return(
          read_http_response_fixture("notifications/create", "success")
        )
      end

      let!(:created_notification) do
        notifications.create(
          customer_id: "C2188C26",
          type: "PAYOUT",
          channel: "WEBHOOK",
          destinations: ["https://foo.bar"],
          config: { retry: true, secret: "00000000000000000000000000000000", hmac_algorithm: "" }
        )
      end

      it_behaves_like "builds correct request", {
        method: :post,
        path: %r{/customers/C2188C26/notifications},
        body: {
          type: "PAYOUT",
          channel: "WEBHOOK",
          destinations: ["https://foo.bar"],
          config: { retry: true, secret: "00000000000000000000000000000000", hmac_algorithm: "" },
        },
      }

      it "returns the created notification" do
        expect(created_notification).to be_a Modulr::Resources::Notifications::Notification
        expect(created_notification.id).to eql("W21082VJGX")
        expect(created_notification.type).to eql("PAYOUT")
        expect(created_notification.channel).to eql("WEBHOOK")
        expect(created_notification.status).to eql("ACTIVE")
        expect(created_notification.destinations).to include("https://eowmy3fgz2o3b8v.m.pipedream.net")
        expect(created_notification.config).to be_a Modulr::Resources::Notifications::Config
      end
    end

    context "when the secret is invalid" do
      before do
        stub_request(:post, %r{/customers/C2188C26/notifications}).to_return(
          read_http_response_fixture("notifications/create", "invalid_secret")
        )
      end

      let!(:params) do
        {
          customer_id: "C2188C26",
          type: "PAYOUT",
          channel: "WEBHOOK",
          destinations: ["https://foo.bar"],
          config: { retry: true, secret: "abc", hmac_algorithm: "" },
        }
      end

      it "raise the correct error" do
        expect { notifications.create(**params) }.to(raise_error do |exception|
          expect(exception).to be_a(Modulr::ClientError)
          expect(exception.status).to be(400)
        end)
      end
    end

    context "when the type is invalid" do
      before do
        stub_request(:post, %r{/customers/C2188C26/notifications}).to_return(
          read_http_response_fixture("notifications/create", "invalid_type")
        )
      end

      let!(:params) do
        {
          customer_id: "C2188C26",
          type: "ACCOUNT_STATEMENT",
          channel: "WEBHOOK",
          destinations: ["https://foo.bar"],
          config: { retry: true, secret: "00000000000000000000000000000000", hmac_algorithm: "" },
        }
      end

      it "raise the correct error" do
        expect { notifications.create(**params) }.to(raise_error do |exception|
          expect(exception).to be_a(Modulr::ClientError)
          expect(exception.status).to be(400)
        end)
      end
    end
  end

  describe "find notification" do
    context "when the id is valid" do
      before do
        stub_request(:get, %r{/notifications}).to_return(
          read_http_response_fixture("notifications/find", "success")
        )
      end

      let!(:found_notification) do
        notifications.find(id: "W21082VKSF")
      end

      it_behaves_like "builds correct request", {
        method: :get,
        path: %r{/notifications},
      }

      it "returns the account" do
        expect(found_notification).to be_a Modulr::Resources::Notifications::Notification
        expect(found_notification.id).to eql("W21082VKSF")
        expect(found_notification.type).to eql("PAYMENT_FILE_UPLOAD")
        expect(found_notification.channel).to eql("WEBHOOK")
        expect(found_notification.status).to eql("ACTIVE")
        expect(found_notification.destinations).to include("https://eowmy3fgz2o3b8v.m.pipedream.net")
        expect(found_notification.config).to be_a Modulr::Resources::Notifications::Config
        expect(found_notification.config.retry).to be true
        expect(found_notification.config.secret).to eql("00000000000000000000000000000000")
        expect(found_notification.config.hmac_algorithm).to eql("hmac-sha512")
      end
    end
  end

  describe "list notifications" do
    context "when params are valid" do
      before do
        stub_request(:get, %r{/notifications}).to_return(
          read_http_response_fixture("notifications/list", "success")
        )
      end

      let!(:notifications_list) do
        notifications.list
      end

      it "returns a collection of notifications" do
        expect(notifications_list).to be_a Modulr::Resources::Notifications::Collection
        expect(notifications_list.count).to be(1)
      end
    end
  end
end
