FactoryGirl.define do
  factory :service do
    sequence(:name)       {|i| "My Service (#{i})"}
    description           "My Description"
    association           :creator, factory: :user
    confirmed_at          Date.new

    factory :service_not_validated do
      confirmed_at        nil
    end
  end
end
