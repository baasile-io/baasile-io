FactoryGirl.define do
  factory :service do
    sequence(:name)       {|i| "My Service (#{i})"}
    description           "My Description"
    association           :user
    confirmed_at          Date.new

    factory :service_locked do
      confirmed_at        nil
    end
  end
end
