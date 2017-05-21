require 'rails_helper'

describe "subscription", type: :request do

  let (:contract) { create :contract, status: :validation }
  let (:route) { contract.proxy.routes.first }

  let (:authentication_api_uri) {
    "http://baasile-io-demo.dev:3042/api/oauth/token"
  }
  let (:request_route_api_uri) {
    "http://baasile-io-demo.dev:3042#{route.local_url('v1')}"
  }

  describe "unauthenticated" do
    it "requires authorization header" do
      get request_route_api_uri

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code" => 710, "title" => "Missing authorization header", "message"=>"The header \"Authorization\" is missing"}
      ]})
      expect(response.status).to eq 400
    end

    it "requires valid access token" do
      get request_route_api_uri,
          headers: {'Authorization' => "Bearer invalid_token"}

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>712, "title"=>"Invalid access token", "message"=>"The access token cannot be decrypted"}
      ]})
      expect(response.status).to eq 401
    end

    it "requires token associated with existing service" do
      access_token = JsonWebToken.encode({service_id: 0, scope: 'my_scope', exp: (Time.now.to_i + 200)})

      get request_route_api_uri,
          headers: {'Authorization' => "Bearer #{access_token}"}

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>713, "title"=>"Client not found", "message"=>"The authenticated client seems to not exist anymore"}
      ]})
      expect(response.status).to eq 401
    end

    it "requires valid scope" do
      access_token = JsonWebToken.encode({service_id: contract.client.id, scope: 'my_scope', exp: (Time.now.to_i + 200)})

      get request_route_api_uri,
          headers: {'Authorization' => "Bearer #{access_token}"}

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>714, "title"=>"Invalid scope", "message"=>"The requested route requires an access token with a bigger authorization scope"}
      ]})
      expect(response.status).to eq 403
    end

    it "requires unexpired access token" do
      access_token = JsonWebToken.encode({service_id: contract.client.id, scope: contract.startup.subdomain, exp: (Time.now.to_i - 1)})

      get request_route_api_uri,
          headers: {'Authorization' => "Bearer #{access_token}"}

      expect(JSON.parse(response.body)).to eq({"errors" => [
        {"code"=>711, "title"=>"Expired access token", "message"=>"The access token has expired"}
      ]})
      expect(response.status).to eq 401
    end
  end

  describe "authenticated" do
    before do
      post authentication_api_uri, 
           params: {
             client_id: contract.client.client_id, 
             client_secret: contract.client.client_secret, 
             scope: contract.startup.subdomain
           }

      response_body = JSON.parse(response.body)
      @access_token = response_body['access_token']
      expect(response.status).to eq 200
    end

    describe "unsubscribed product" do
      before :each do
        contract.destroy
      end

      it "requires contract" do
        get request_route_api_uri,
            headers: {'Authorization' => "Bearer #{@access_token}"}

        expect(JSON.parse(response.body)).to eq({"errors" => [
          {"code"=>801, "title"=>"Contract not found", "message"=>"No contract found with this product"}
        ]})
        expect(response.status).to eq 403
      end
    end

    describe "subscribed" do
      describe "not active subscription" do
        before :each do
          contract.update_attribute(:status, :creation)
        end

        it "returns error" do
          get request_route_api_uri,
              headers: {'Authorization' => "Bearer #{@access_token}"}

          expect(JSON.parse(response.body)).to eq({"errors" => [
            {"code"=>802, "title"=>"Invalid contract status", "message"=>"No active contract found with this product"}
          ]})
          expect(response.status).to eq 403
        end
      end

      describe "waiting for production" do
        before :each do
          contract.update_attribute(:status, :waiting_for_production)
        end

        it "returns error" do
          get request_route_api_uri,
              headers: {'Authorization' => "Bearer #{@access_token}"}

          expect(JSON.parse(response.body)).to eq({"errors" => [
            {"code"=>806, "title"=>"Waiting for production", "message"=>"Production phase has not yet started"}
          ]})
          expect(response.status).to eq 403
        end
      end

      describe "active subscription" do
        before :each do
          stub_request(:get, route.uri_test).
            to_return(
              status: 276,
              body: "Test phase",
              headers: {}
            )

          stub_request(:get, route.uri).
            to_return(
              status: 277,
              body: "Production phase",
              headers: {}
            )

          allow(SecureRandom).to receive(:uuid).and_return('my_measure_token_id')
        end

        describe "request test phase" do
          it "redirects to test uri" do
            get request_route_api_uri,
                headers: {'Authorization' => "Bearer #{@access_token}"}

            expect(response.body).to eq "Test phase"
            expect(response.status).to eq 276
          end
        end

        describe "request waiting_for_production phase" do
          before :each do
            contract.update_attribute(:status, :waiting_for_production)
          end

          it "requires production phase", focus: true do
            get request_route_api_uri,
                headers: {'Authorization' => "Bearer #{@access_token}"}

            expect(JSON.parse(response.body)).to eq({"errors" => [
              {"code"=>806, "title"=>"Waiting for production", "message"=>"Production phase has not yet started"}
            ]})
            expect(response.status).to eq 403
          end
        end

        describe "request production phase" do
          before :each do
            contract.update_attribute(:status, :validation_production)
          end

          it "requires started contract" do
            contract.update_attributes({start_date: Date.today + 1.day, end_date: Date.today + 2.days})

            get request_route_api_uri,
                headers: {'Authorization' => "Bearer #{@access_token}"}

            expect(JSON.parse(response.body)).to eq({"errors" => [
              {"code"=>804, "title"=>"Contract not started", "message"=>"Production phase will start later"}
            ]})
            expect(response.status).to eq 403
          end

          it "requires not ended contract" do
            contract.update_attributes({start_date: Date.today - 2.days, end_date: Date.today - 1.day})

            get request_route_api_uri,
                headers: {'Authorization' => "Bearer #{@access_token}"}

            expect(JSON.parse(response.body)).to eq({"errors" => [
              {"code"=>805, "title"=>"Contract ended", "message"=>"Production phase has ended"}
            ]})
            expect(response.status).to eq 403
          end

          it "requires active contract" do
            contract.update_attributes({is_active: false})

            get request_route_api_uri,
                headers: {'Authorization' => "Bearer #{@access_token}"}

            expect(JSON.parse(response.body)).to eq({"errors" => [
              {"code"=>807, "title"=>"Contract not active", "message"=>"The contract has been temporarily deactivated"}
            ]})
            expect(response.status).to eq 403
          end

          describe "success" do
            describe "is_evergreen" do
              it "extends expired contract" do
                contract.update_attributes(
                  {
                    is_evergreen: true,
                    start_date: Date.today - 10.days,
                    end_date: Date.today - 1.day
                  }
                )
                contract.price.update_attributes(
                  {
                    pricing_duration_type: :monthly
                  }
                )

                get request_route_api_uri,
                    headers: {'Authorization' => "Bearer #{@access_token}"}

                expect(response.body).to eq "Production phase"
                expect(contract.reload.end_date).to eq Date.today - 1.day + 1.month
                expect(response.status).to eq 277
              end
            end

            it "redirects to production uri" do
              get request_route_api_uri,
                  headers: {'Authorization' => "Bearer #{@access_token}"}

              expect(response.body).to eq "Production phase"
              expect(response.status).to eq 277
            end
          end
        end
      end
    end
  end

end