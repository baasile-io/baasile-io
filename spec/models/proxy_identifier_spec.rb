require 'rails_helper'

RSpec.describe ProxyIdentifier, type: :model do
  describe "attributes" do
    before :each do
      @poxy_identifier = build :proxy_identifier
    end

    describe "encrypted_secret" do
      it "encrypt client_secret on before_save" do
        client_secret = 'client_secret'
        @poxy_identifier.client_secret = client_secret
        @poxy_identifier.encrypted_secret = nil
        @poxy_identifier.save
        expect(@poxy_identifier.encrypted_secret).to_not be_nil
        expect(@poxy_identifier.encrypted_secret).to_not eq client_secret
      end
    end
  end
end
