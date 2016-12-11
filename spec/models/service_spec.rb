require 'rails_helper'

RSpec.describe Service, type: :model do
  before :each do
    @service = create :service
    @service_locked = create :service_locked
  end

  describe "attributes" do
    describe "validated?" do
      it "returns false" do
        expect(@service_locked.is_locked?).to be_falsey
      end

      it "returns true" do
        expect(@service.validated?).to be_truthy
      end
    end
  end

  describe "user rights" do
    it "assigns :developer role to the creator" do
      expect(@service.user.has_role?(:developer, @service)).to be_truthy
    end
  end
end
