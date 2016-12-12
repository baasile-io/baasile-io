require 'rails_helper'

RSpec.describe Service, type: :model do
  before :each do
    @service = create :service
    @service_not_activated = create :service_not_activated
  end

  describe "attributes" do
    describe "is_activated?" do
      it "returns false when confirmed_at is nil" do
        expect(@service.is_activated?).to be_truthy
        expect(@service_not_activated.is_activated?).to be_falsey

        @service.confirmed_at = nil
        expect(@service.is_activated?).to be_falsey
      end
    end

    describe "client_id" do
      it "must be a valid uuid" do
        @service.client_id = 'abc'
        expect(@service.valid?).to be_falsey

        @service.client_id = 'bad85eb9-0713-4da7-8d36-07a8e4b00eab'
        expect(@service.valid?).to be_truthy

        @service.client_id = 'bad85eb9-0713-4da7-8d3607a8e-4b00eab'
        expect(@service.valid?).to be_falsey
      end

      it "can be blank if not activated" do
        @service_not_activated.client_id = nil
        expect(@service_not_activated.valid?).to be_truthy
      end
    end

    describe "client_secret" do
      it "must be a valid secret" do
        @service.client_secret = 'abc'
        expect(@service.valid?).to be_falsey

        @service.client_secret = 'abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmnop'
        expect(@service.valid?).to be_truthy

        @service.client_secret = 'abcdefghijklmn-pabcdefghijklmnopabcdefghij-lmnopabcdefghijklmnop'
        expect(@service.valid?).to be_falsey
      end

      it "can be blank if not activated" do
        @service_not_activated.client_secret = nil
        expect(@service_not_activated.valid?).to be_truthy
      end
    end
  end

  describe "generate ID and SECRET" do
    it "implements ID generator" do
      s = Service.new
      s.generate_client_id!
      expect(s.client_id).to match(/\A[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\z/i)
    end

    it "implements SECRET generator" do
      s = Service.new
      s.generate_client_secret!
      expect(s.client_secret).to match(/\A[a-z0-9]{64}\z/i)
    end
  end

  describe "user rights" do
    it "assigns :developer role to the creator" do
      expect(@service.user.has_role?(:developer, @service)).to be_truthy
    end
  end
end
