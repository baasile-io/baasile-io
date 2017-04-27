require 'rails_helper'

describe "authentication", type: :request do

  let(:authentication_uri) {"http://baasile-io-demo.dev:3042/api/oauth/token"}
  let(:client) {create :service, service_type: :client}

  describe "errors" do
    describe "client_credentials" do
      it "requires client_id" do
        post authentication_uri

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Missing client_id"}]})
      end

      it "requires valid client_id" do
        post authentication_uri, {client_id: 'invalid'}

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Invalid client_id"}]})
      end

      it "requires client_secret" do
        post authentication_uri, {client_id: client.client_id}

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Missing client_secret"}]})
      end

      it "requires valid client_secret" do
        post authentication_uri, {client_id: client.client_id, client_secret: 'invalid'}

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Client authentication failed"}]})
      end
    end

    describe "refresh_token" do
      it "requires refresh_token" do
        post "#{authentication_uri}?grant_type=refresh_token"

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Missing refresh_token"}]})
      end

      it "requires valid refresh_token" do
        post "#{authentication_uri}?grant_type=refresh_token", {refresh_token: 'invalid'}

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Invalid refresh_token"}]})
      end
    end
  end

  describe "success" do
    describe "client_credentials" do
      it "returns access token with scope" do
        allow(JsonWebToken).to receive(:encode).and_return('my_access_token').once

        post authentication_uri, {client_id: client.client_id, client_secret: client.client_secret, scope: 'scope1 scope2'}

        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json["access_token"]).to eq('my_access_token')
        expect(response_json["scope"]).to eq('scope1 scope2')
      end
    end

    describe "refresh_token" do
      it "returns access token with scope" do
        allow(JsonWebToken).to receive(:encode).and_return('my_access_token').once
        refresh_token = create :refresh_token, value: 'my_refresh_token', scope: 'scope1 scope2'

        post "#{authentication_uri}?grant_type=refresh_token", {refresh_token: refresh_token.value}

        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json["access_token"]).to eq('my_access_token')
        expect(response_json["scope"]).to eq('scope1 scope2')
      end
    end
  end

end