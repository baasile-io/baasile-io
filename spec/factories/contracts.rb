FactoryGirl.define do
  factory :contract do
    sequence(:name)        {|i| "My Contract #{i}"}
    sequence(:code)        {|i| i}
    association            :client, factory: :client_service
    association            :proxy
    expected_start_date    Date.today + 1.month
    expected_end_date      Date.today + 6.months

    after :create do |contract|
      create :price, contract: contract if contract.price.nil?
    end
  end
end
