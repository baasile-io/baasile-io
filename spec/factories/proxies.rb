FactoryGirl.define do
  factory :proxy do
    sequence(:name)       {|i| "My Proxy (#{i})"}
    sequence(:alias)      {|i| "myproxy#{i}"}
    description           "Description of my proxy"
    association           :service
    association           :user
    association           :proxy_parameter
  end
end
