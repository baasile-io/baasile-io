FactoryGirl.define do
  factory :functionality do
    sequence(:name)       {|i| "My Functionality (#{i})"}
    description           "Description of my functionality"
    functionality_type    1
    association           :service
    association           :user
  end
end
