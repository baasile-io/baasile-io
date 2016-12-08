require 'rails_helper'
require 'features_helper'

describe "the signin process" do
  before :each do
    User.create(email: 'user@example.com', password: 'password')
  end

  describe "email confirmation" do
    it "does not sign me in" do
      visit '/users/sign_in'

      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'password'

      click_button 'Log in'
      expect(page).to have_content 'You have to confirm your email address before continuing.'
    end
  end
end
