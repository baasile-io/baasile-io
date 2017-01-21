FactoryGirl.define do
  factory :proxy_identifier do
    client_id       'client_id'
    client_secret   'abc'
    association     :user
    association     :proxy
  end
end
