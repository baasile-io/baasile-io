FactoryGirl.define do
  factory :contract do
    name                   "My Contract"
    code                   "001"
    association            :client, factory: :client_service
    association            :proxy
    expected_start_date    Date.today + 1.month
    expected_end_date      Date.today + 6.months
  end
end
