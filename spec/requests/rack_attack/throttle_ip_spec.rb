require 'rails_helper'

describe "throttle ip", type: :request do

  let(:platform_uri) {"http://baasile-io-demo.dev:3042/"}
  let(:client) {create :service, service_type: :client}

  it "denies access to spamers according to Appconfig max_requests_per_hour" do
    allow(Appconfig).to receive(:get).with(:max_requests_per_hour).and_return(10)

    10.times do
      get platform_uri
      expect(response.status).to eq 200
    end

    get platform_uri
    expect(response.status).to eq 503
  end

end