require 'rails_helper'

RSpec.describe Service, type: :model do
  before :each do
    @service = create :service
    @service_not_validated = create :service_not_validated
  end

  describe "attributes" do
    describe "validated?" do
      it "returns false" do
        expect(@service_not_validated.validated?).to be_falsey
      end

      it "returns true" do
        expect(@service.validated?).to be_truthy
      end
    end
  end
end
