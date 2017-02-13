FactoryGirl.define do
  factory :measurement do
    client_id 1
    association           :service
    association           :proxy
    association           :route
    requests_count 1
  end
end
