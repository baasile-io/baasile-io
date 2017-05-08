require 'features_helper'

describe "the signin process", type: :feature do

  let(:platform_uri) { "#{Capybara.app_host}" }

  describe "with confirmed user" do
    before :each do
      @user = create :user, language: 'fr'
    end

    it "sign in" do
      visit "#{platform_uri}/fr/auth/sign_in"

      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password

      within ".actions" do
        click_button 'Se connecter'
      end

      expect(page).to have_content 'Tickets'

      visit "#{platform_uri}/fr/profile"

      expect(page).to have_content 'Modifier mon compte'
    end
  end

  describe "with unconfirmed user" do
    before :each do
      @unconfirmed_user = create :unconfirmed_user
    end

    it "does not sign in" do
      visit "#{platform_uri}/fr/auth/sign_in"

      fill_in 'user_email', with: @unconfirmed_user.email
      fill_in 'user_password', with: @unconfirmed_user.password

      within ".actions" do
        click_button 'Se connecter'
      end

      expect(page).to have_content I18n.t('devise.failure.unconfirmed', locale: :fr)
    end
  end
end
