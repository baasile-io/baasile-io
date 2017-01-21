require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = create :user
    @user2 = create :user
  end

  describe "email" do
    it "must be unique" do
      @user2.email = @user.email
      expect(@user2.valid?).to be_falsey
      expect(@user2.errors.messages[:email]).to_not be_empty
    end
  end
end