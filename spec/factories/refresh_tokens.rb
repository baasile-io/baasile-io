FactoryGirl.define do
  factory :refresh_token do
    sequence(:value)         {|i| "my_refresh_token_#{i}"}
    expires_at              DateTime.now + 1.hour
    association             :service
    scope                   ""
  end
end
