require 'features_helper'

describe "the signin process", type: :feature do

  describe "confirmed user" do
    before :each do
      @user = create :user
    end

    it "sign me in" do
      visit '/users/sign_in'

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password

      within ".actions" do
        click_button 'Sign in'
      end

      expect(page).to have_content 'Sign out'
    end
  end

  describe "unconfirmed user" do
    before :each do
      @unconfirmed_user = create :unconfirmed_user
    end

    it "does not sign me in" do
      visit '/users/sign_in'

      fill_in 'user_email', with: @unconfirmed_user.email
      fill_in 'Password', with: @unconfirmed_user.password

      within ".actions" do
        click_button 'Sign in'
      end

      expect(page).to have_content I18n.t('devise.failure.unconfirmed')
    end
  end
end
