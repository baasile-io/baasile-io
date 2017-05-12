require 'rails_helper'

RSpec.describe Proxy, type: :model do
  before :each do
    service = create :service
    @proxy = create :proxy, service: service
    @proxy2 = create :proxy, service: service
  end

  describe "attributes" do
    describe "name" do
      it "is required" do
        @proxy.name = nil
        expect(@proxy.valid?).to be_falsey
        expect(@proxy.errors.messages[:name]).to_not be_empty
      end

      it "must be unique" do
        @proxy2.name = @proxy.name
        expect(@proxy2.valid?).to be_falsey
        expect(@proxy2.errors.messages[:name]).to_not be_empty
      end
    end

    describe "name" do

    end

    describe "description" do
      it "is required" do
        @proxy.description = nil
        expect(@proxy.valid?).to be_falsey
        expect(@proxy.errors.messages[:description]).to_not be_empty
      end
    end

    describe "cache_token" do
      it "returns a string" do
        @proxy.proxy_parameter.authorization_mode = :null
        expect(@proxy.cache_token).to eq "proxy_cache_token_null_#{@proxy.id}_#{@proxy.updated_at.strftime('%Y%M%d%H%I%S')}"

        @proxy.proxy_parameter.authorization_mode = :oauth2
        expect(@proxy.cache_token).to eq "proxy_cache_token_oauth2_#{@proxy.id}_#{@proxy.updated_at.strftime('%Y%M%d%H%I%S')}"
      end
    end
  end
end
