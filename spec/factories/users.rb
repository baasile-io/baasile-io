FactoryGirl.define do
  factory :user do
    sequence(:email)        {|i| "email-#{i}@baasile-io.net"}
    gender                  :male
    first_name              "First name"
    last_name               "Last name"
    password                "Complicated01!"
    password_confirmation   "Complicated01!"
    confirmed_at            Date.today

    factory :unconfirmed_user do
      confirmed_at          nil
    end
  end
end
