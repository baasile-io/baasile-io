require 'rails_helper'

describe "measure token", type: :request do

  let (:startup) { create :startup_service }
  let (:client) { create :client_service }
  let (:proxy) { create :proxy, service: startup }
  let (:route) { create :route, proxy: proxy, measure_token_activated: true }
  let (:price) { create :price, proxy: proxy, pricing_type: :per_parameter }
  let (:contract) { create :contract, client: client, proxy: proxy, price: price, status: :validation }

  let (:authentication_api_uri) {
    "http://baasile-io-demo.dev:3042/api/oauth/token"
  }
  let (:request_route_api_uri) {
    "http://baasile-io-demo.dev:3042#{route.local_url('v1')}"
  }

  # TODO
  # TO BE EXPORTED OUT OF THIS SPEC FILE
  describe "unauthenticated" do
    it "requires authorization header" do
      get request_route_api_uri

      expect(response.status).to eq 400
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Missing authorization header"}]})
    end
  end

  describe "authenticated" do
    before :each do
      route #create route in DB

      post authentication_api_uri, {client_id: contract.client.client_id, client_secret: contract.client.client_secret, scope: contract.startup.subdomain}

      expect(response.status).to eq 200
      response_body = JSON.parse(response.body)
      @access_token = response_body['access_token']
    end

    describe "unsubscribed product" do
      it "requires contract" do
        get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

        expect(response.status).to eq 403
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status"=>403, "title"=>"No subscription to this product"}]})
      end
    end

    describe "subscribed" do
      before :each do
        stub_request(:get, route.uri_test).
          with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
            }
          ).
          to_return(
            status: 276,
            body: "My body",
            headers: {}
          )
      end

      describe "request" do
        it "generates a new measure token", focus: true do
          allow(SecureRandom).to receive(:uuid).and_return('my_measure_token_id').once

          get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

          expect(response.status).to eq 276
          expect(response.body).to eq "My body"
          expect(response.headers['MeasureTokenID']).to eq('my_measure_token_id')
        end

        it "returns error when unknown measure token" do
          get request_route_api_uri, nil, {
            'Authorization' => "Bearer #{@access_token}",
            'MeasureTokenID' => 'unknwon_measure_token'
          }

          expect(response.status).to eq 400
        end
      end
    end
  end

end