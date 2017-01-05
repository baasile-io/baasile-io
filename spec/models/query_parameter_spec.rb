require 'rails_helper'

RSpec.describe QueryParameter, type: :model do
  before :each do
    @query_parameter = create :query_parameter
  end

  describe "attributes" do
    it "requires a name" do
      @query_parameter.name = nil
      expect(@query_parameter.valid?).to be_falsey
      expect(@query_parameter.errors.messages[:name]).to_not be_empty
    end
  end
end
