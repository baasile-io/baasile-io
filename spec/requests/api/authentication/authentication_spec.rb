require 'rails_helper'

describe "authentication", type: :request do

  let(:authentication_uri) {"http://baasile-io-demo.dev:3042/api/oauth/token"}
  let(:client) {create :service, service_type: :client}

  describe "errors" do
    describe "client_credentials" do
      it "requires scope" do
        post authentication_uri,
             params: {client_id: client.client_id}

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>706, "title"=>"Missing scope", "message"=>"The parameter \"scope\" is missing"}
        ]})
        expect(response.status).to eq 400
      end

      it "requires client_id" do
        post authentication_uri,
             params: {
               scope: 'scope'
             }

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>702, "title"=>"Missing client_id", "message"=>"The parameter \"client_id\" is missing"}
        ]})
        expect(response.status).to eq 400
      end

      it "requires valid client_id" do
        post authentication_uri,
             params: {
               scope: 'scope',
               client_id: 'invalid'}

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>701, "title"=>"Invalid client_id", "message"=>"The value of the parameter \"client_id\" is unknown"}
        ]})
        expect(response.status).to eq 400
      end

      it "requires client_secret" do
        post authentication_uri,
             params: {
               scope: 'scope',
               client_id: client.client_id
             }

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>703, "title"=>"Missing client_secret", "message"=>"The parameter \"client_secret\" is missing"}
        ]})
        expect(response.status).to eq 400
      end

      it "requires valid client_secret" do
        post authentication_uri,
             params: {
               scope: 'scope',
               client_id: client.client_id,
               client_secret: 'invalid'
             }

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>705, "title"=>"Bad credentials", "message"=>"The provided credentials are invalid"}
        ]})
        expect(response.status).to eq 400
      end
    end

    describe "refresh_token" do
      it "requires refresh_token" do
        post "#{authentication_uri}?grant_type=refresh_token"

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>709, "title"=>"Missing refresh token", "message"=>"The parameter \"refresh_token\" is missing"}
        ]})
        expect(response.status).to eq 400
      end

      it "requires valid refresh_token" do
        post "#{authentication_uri}?grant_type=refresh_token",
             params: {refresh_token: 'invalid'}

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>707, "title"=>"Invalid refresh token", "message"=>"The refresh token is invalid"}
        ]})
        expect(response.status).to eq 400
      end

      it "returns error when expired refresh_token" do
        refresh_token = create :refresh_token,
                               value: 'my_refresh_token',
                               scope: 'scope1 scope2'
        refresh_token.update_attribute(:expires_at, DateTime.now - 1.day)

        post "#{authentication_uri}?grant_type=refresh_token",
             params: {refresh_token: refresh_token.value}

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>708, "title"=>"Expired refresh token", "message"=>"The refresh token has expired"}
        ]})
        expect(response.status).to eq 401
      end
    end
  end

  describe "success" do
    describe "client_credentials" do
      it "returns access token with scope" do
        allow(JsonWebToken).to receive(:encode).and_return('my_access_token').once

        post authentication_uri,
             params: {
               client_id: client.client_id,
               client_secret: client.client_secret,
               scope: 'scope1 scope2'
             }

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

        post "#{authentication_uri}?grant_type=refresh_token",
             params: {refresh_token: refresh_token.value}

        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json["access_token"]).to eq('my_access_token')
        expect(response_json["scope"]).to eq('scope1 scope2')
      end
    end
  end

end