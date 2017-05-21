FactoryGirl.define do
  factory :measure_token do
    association           :contract
    contract_status       'validation_production'
    sequence(:value)      { |i| "measure_token_value_#{i}" }
    is_active             true
  end
end
