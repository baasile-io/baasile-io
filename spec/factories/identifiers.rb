FactoryGirl.define do
  factory :identifier do
    sequence(:client_id)         {|i| "client_id#{i}"}
    sequence(:encrypted_secret)  {|i| "client_secret#{i}"}
  end
end
