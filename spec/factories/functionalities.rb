FactoryGirl.define do
  factory :functionality do
    sequence(:name)       {|i| "My Functionality (#{i})"}
    description           "Description of my functionality"
    association           :service
    association           :user

    factory :proxy do
      type                  :proxy
    end
  end
end
