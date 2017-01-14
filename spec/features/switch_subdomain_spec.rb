require 'features_helper'

describe "switching subdomain", type: :feature do
  before :each do
    @user = create :user
    @service = create :service, user: @user

    @proxy = build :proxy, user: @user, service: @service
    @proxy.save

    sign_in_with @user
  end

  it "works" do
    visit "/services/#{@service.id}"
    click_on 'Dashboard'
    visit "/back_office/proxies/#{@proxy.id}"

    @user.reload

    expect(current_path).to eq "/back_office/proxies/#{@proxy.id}"
    expect(@user.current_subdomain).to eq @service.subdomain
    expect(page).to have_content @proxy.name
  end
end
