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

      expect(response.status).to eq 400
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 400, "title" => "Missing authorization header"}]})
    end

    it "requires valid access token" do
      get request_route_api_uri, nil, {'Authorization' => "Bearer invalid_token"}

      expect(response.status).to eq 403
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 403, "title" => "Signature verification failed"}]})
    end

    it "requires token associated with existing service" do
      access_token = JsonWebToken.encode({service_id: 0, scope: 'my_scope', exp: (Time.now.to_i + 200)})

      get request_route_api_uri, nil, {'Authorization' => "Bearer #{access_token}"}

      expect(response.status).to eq 403
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 403, "title" => "Client ID not found in database"}]})
    end

    it "requires valid scope" do
      access_token = JsonWebToken.encode({service_id: contract.client.id, scope: 'my_scope', exp: (Time.now.to_i + 200)})

      get request_route_api_uri, nil, {'Authorization' => "Bearer #{access_token}"}

      expect(response.status).to eq 403
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 403, "title" => "Unknown/invalid scope(s): [\"my_scope\"]. Required scope: \"#{contract.startup.subdomain}\"."}]})
    end

    it "requires unexpired access token" do
      access_token = JsonWebToken.encode({service_id: contract.client.id, scope: contract.startup.subdomain, exp: (Time.now.to_i - 1)})

      get request_route_api_uri, nil, {'Authorization' => "Bearer #{access_token}"}

      expect(response.status).to eq 403
      expect(JSON.parse(response.body)).to eq({"errors" => [{"status" => 403, "title" => "This authorization token has expired"}]})
    end
  end

  describe "authenticated" do
    before do
      post authentication_api_uri, {client_id: contract.client.client_id, client_secret: contract.client.client_secret, scope: contract.startup.subdomain}

      expect(response.status).to eq 200
      response_body = JSON.parse(response.body)
      @access_token = response_body['access_token']
    end

    describe "unsubscribed product" do
      before :each do
        contract.destroy
      end

      it "requires contract" do
        get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

        expect(response.status).to eq 403
        expect(JSON.parse(response.body)).to eq({"errors" => [{"status"=>403, "title"=>"No subscription to this product"}]})
      end
    end

    describe "subscribed" do
      describe "not active subscription" do
        before :each do
          contract.update_attribute(:status, :creation)
        end

        it "returns error" do
          get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

          expect(response.status).to eq 403
          expect(JSON.parse(response.body)).to eq({"errors" => [{"status"=>403, "title"=>"No active subscription to this product (status: creation)"}]})
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
            get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

            expect(response.status).to eq 276
            expect(response.body).to eq "Test phase"
          end
        end

        describe "request production phase" do
          before :each do
            contract.update_attribute(:status, :validation_production)
          end

          it "requires started contract" do
            contract.update_attributes({start_date: Date.today + 1.day, end_date: Date.today + 2.days})

            get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

            expect(response.status).to eq 403
            expect(JSON.parse(response.body)).to eq({"errors" => [{"status"=>403, "title"=>"Production phase will start on #{contract.start_date.strftime('%Y-%m-%d')}"}]})
          end

          it "requires not ended contract" do
            contract.update_attributes({start_date: Date.today - 2.days, end_date: Date.today - 1.day})

            get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

            expect(response.status).to eq 403
            expect(JSON.parse(response.body)).to eq({"errors" => [{"status"=>403, "title"=>"Production phase ended on #{contract.end_date.strftime('%Y-%m-%d')}"}]})
          end

          describe "success" do
            describe "is_evergreen" do
              it "extends expired contract" do
                contract.update_attributes(
                  {
                    is_evergreen: true,
                    contract_duration_type: :monthly,
                    start_date: Date.today - 10.days,
                    end_date: Date.today - 1.day
                  }
                )

                get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

                expect(response.status).to eq 277
                expect(response.body).to eq "Production phase"
                expect(contract.reload.end_date).to eq Date.today - 1.day + 1.month
              end
            end

            it "redirects to production uri" do
              get request_route_api_uri, nil, {'Authorization' => "Bearer #{@access_token}"}

              expect(response.status).to eq 277
              expect(response.body).to eq "Production phase"
            end
          end
        end
      end
    end
  end

end