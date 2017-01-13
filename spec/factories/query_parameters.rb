FactoryGirl.define do
  factory :query_parameter do
    name "MyString"
    mode 1
    association :route
    association :user
  end
end
