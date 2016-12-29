require 'rails_helper'

RSpec.describe Proxy, type: :model do
  before :each do
    @proxy = create :proxy
  end

  describe "attributes" do
    it "requires a name" do
      @proxy.name = nil
      expect(@proxy.valid?).to be_falsey
      expect(@proxy.errors.messages[:name]).to_not be_empty
    end

    it "requires a description" do
      @proxy.description = nil
      expect(@proxy.valid?).to be_falsey
      expect(@proxy.errors.messages[:description]).to_not be_empty
    end
  end
end
