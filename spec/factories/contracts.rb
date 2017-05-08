FactoryGirl.define do
  factory :contract do
    sequence(:client_code) {|i| "C#{i}"}
    sequence(:startup_code){|i| "S#{i}"}
    association            :client, factory: :client_service
    association            :proxy
    expected_start_date    Date.today + 1.month
    expected_end_date      Date.today + 6.months

    after :create do |contract|
      create :price, contract: contract if contract.price.nil?
    end
  end
end
