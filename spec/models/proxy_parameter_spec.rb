require 'rails_helper'

RSpec.describe ProxyParameter, type: :model do
  before :each do
    @proxy_parameter = create :proxy_parameter
  end

  describe "attributes" do

    describe "required attributes" do
      it "requires an authorization mode" do
        @proxy_parameter.authorization_mode = nil
        expect(@proxy_parameter.valid?).to be_falsey
        expect(@proxy_parameter.errors.messages[:authorization_mode]).to_not be_empty
      end

      it "requires a protocol" do
        @proxy_parameter.protocol = nil
        expect(@proxy_parameter.valid?).to be_falsey
        expect(@proxy_parameter.errors.messages[:protocol]).to_not be_empty
      end

      it "requires a hostname" do
        @proxy_parameter.hostname = nil
        expect(@proxy_parameter.valid?).to be_falsey
        expect(@proxy_parameter.errors.messages[:hostname]).to_not be_empty
      end

      it "requires a port" do
        @proxy_parameter.port = nil
        expect(@proxy_parameter.valid?).to be_falsey
        expect(@proxy_parameter.errors.messages[:port]).to_not be_empty
      end

      it "does not require client_id, client_secret and authorization_url" do
        @proxy_parameter.client_id = nil
        @proxy_parameter.client_secret = nil
        @proxy_parameter.authorization_url = nil
        expect(@proxy_parameter.valid?).to be_truthy
      end

      [:oauth2].each do |auth_mode|
        describe "authorization_mode: #{auth_mode}" do
          before :each do
            @proxy_parameter.authorization_mode = auth_mode
            @proxy_parameter.save
          end

          it "requires client_id" do
            @proxy_parameter.client_id = nil
            expect(@proxy_parameter.valid?).to be_falsey
            expect(@proxy_parameter.errors.messages[:client_id]).to_not be_empty
          end

          it "requires client_secret" do
            @proxy_parameter.client_secret = nil
            expect(@proxy_parameter.valid?).to be_falsey
            expect(@proxy_parameter.errors.messages[:client_secret]).to_not be_empty
          end

          it "requires authorization_url" do
            @proxy_parameter.authorization_url = nil
            expect(@proxy_parameter.valid?).to be_falsey
            expect(@proxy_parameter.errors.messages[:authorization_url]).to_not be_empty
          end
        end
      end
    end

    describe "format validation" do
      describe "authorization_url" do
        it "must start with a slash character" do
          @proxy_parameter.authorization_mode = :oauth2

          @proxy_parameter.authorization_url = '/abc'
          expect(@proxy_parameter.valid?).to be_truthy

          @proxy_parameter.authorization_url = 'abc'
          expect(@proxy_parameter.valid?).to be_falsey
          expect(@proxy_parameter.errors.messages[:authorization_url]).to_not be_empty
        end
      end

      describe "port" do
        it "must be a positive number" do
          @proxy_parameter.port = 42
          expect(@proxy_parameter.valid?).to be_truthy

          @proxy_parameter.port = 0
          expect(@proxy_parameter.valid?).to be_falsey
          expect(@proxy_parameter.errors.messages[:port]).to_not be_empty

          @proxy_parameter.port = -42
          expect(@proxy_parameter.valid?).to be_falsey
          expect(@proxy_parameter.errors.messages[:port]).to_not be_empty
        end
      end
    end

    describe "virtual attributes" do
      describe "authorization_required?" do
        it "return false if authorization_mode is :null" do
          @proxy_parameter.authorization_mode = :null
          expect(@proxy_parameter.authorization_required?).to be_falsey
        end

        [:oauth2].each do |auth_mode|
          it "return false if authorization_mode is :#{auth_mode}" do
            @proxy_parameter.authorization_mode = auth_mode
            expect(@proxy_parameter.authorization_required?).to be_truthy
          end
        end
      end
    end

  end
end
