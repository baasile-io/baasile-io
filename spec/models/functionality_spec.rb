require 'rails_helper'

RSpec.describe Functionality, type: :model do
  before :each do
    @functionality = create :functionality
  end

  describe "attributes" do
    it "requires a name" do
      @functionality.name = nil
      expect(@functionality.valid?).to be_falsey
      expect(@functionality.errors.messages[:name]).to_not be_empty
    end

    it "requires a description" do
      @functionality.description = nil
      expect(@functionality.valid?).to be_falsey
      expect(@functionality.errors.messages[:description]).to_not be_empty
    end
  end
end
