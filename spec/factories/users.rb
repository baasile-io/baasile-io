FactoryGirl.define do
  factory :user do
    sequence(:email)        {|i| "email-#{i}@baasile-io.net"}
    password                "Complicated01!"
    password_confirmation   "Complicated01!"
    confirmed_at            Date.new

    factory :unconfirmed_user do
      confirmed_at          nil
    end
  end
end
