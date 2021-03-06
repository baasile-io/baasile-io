FactoryGirl.define do
  factory :proxy do
    sequence(:name)       {|i| "My Proxy (#{i})"}
    sequence(:subdomain)  {|i| "myproxy#{i}"}
    description           "Description of my proxy"
    association           :service
    association           :user
    association           :proxy_parameter
    association           :proxy_parameter_test, factory: :proxy_parameter

    after :create do |proxy|
      create_list(:route, 3, proxy: proxy)
    end
  end
end
