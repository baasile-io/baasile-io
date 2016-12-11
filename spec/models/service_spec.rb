require 'rails_helper'

RSpec.describe Service, type: :model do
  before :each do
    @service = create :service
    @service_not_activated = create :service_not_activated
  end

  describe "attributes" do
    describe "is_activated?" do
      it "returns false" do
        expect(@service_not_activated.is_activated?).to be_falsey
      end

      it "returns true" do
        expect(@service.is_activated?).to be_truthy
      end
    end
  end

  describe "user rights" do
    it "assigns :developer role to the creator" do
      expect(@service.user.has_role?(:developer, @service)).to be_truthy
    end
  end
end
