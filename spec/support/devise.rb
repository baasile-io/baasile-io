def sign_in_with(user)
  visit '/users/sign_in'

  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: user.password

  within '.actions' do
    click_on 'Sign in'
  end
end

def sign_out
  visit '/users/sign_out'
end
