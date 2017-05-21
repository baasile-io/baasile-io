require 'rails_helper'

describe "subscription", type: :request do

  let (:service) { create :service }

  let (:authentication_api_uri) {
    "http://baasile-io-demo.dev:3042/api/oauth/token"
  }
  let (:api_uri) {
    "http://baasile-io-demo.dev:3042/api/v1"
  }

  describe "unauthenticated" do
    it "requires authorization header" do
      get "#{api_uri}/services"

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>710, "title"=>"Missing authorization header", "message"=>"The header \"Authorization\" is missing"}
      ]})
      expect(response.status).to eq 400
    end

    it "requires valid access token" do
      get "#{api_uri}/services",
          headers: {'Authorization' => "Bearer invalid_token"}

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>712, "title"=>"Invalid access token", "message"=>"The access token cannot be decrypted"}
      ]})
      expect(response.status).to eq 401
    end

    it "does not require scope" do
      access_token = JsonWebToken.encode({service_id: service.id, scope: '', exp: (Time.now.to_i + 200)})

      get "#{api_uri}/services",
          headers: {'Authorization' => "Bearer #{access_token}"}

      expect(response.status).to eq 200
    end
  end

  describe "authenticated" do
    before do
      post authentication_api_uri,
           params: {
             client_id: service.client_id,
             client_secret: service.client_secret,
             scope: service.subdomain
           }

      expect(response.status).to eq 200
      response_body = JSON.parse(response.body)
      @access_token = response_body['access_token']
    end

    describe "catalog" do
      before do
        @other_service = create :service
      end

      it "returns empty public services" do
        get "#{api_uri}/services",
            headers: {'Authorization' => "Bearer #{@access_token}"}

        expect(JSON.parse(response.body)).to eq({"data" => []})
        expect(response.status).to eq 200
      end

      it "returns public services" do
        @other_service.update_attribute(:public, true)

        get "#{api_uri}/services",
            headers: {'Authorization' => "Bearer #{@access_token}"}

        expect(JSON.parse(response.body)).to eq({"data" => [
          {"id"=>@other_service.subdomain,
           "type"=>"Service",
           "attributes"=>{
             "name"=>@other_service.name,
             "description"=>@other_service.description,
             "website"=>nil,
             "proxies"=>[]
           }}
        ]})
        expect(response.status).to eq 200
      end
    end
  end

end