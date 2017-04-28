FactoryGirl.define do
  factory :price do
    name                  "My Price"
    base_cost             200.0
    free_count            10
    deny_after_free_count true
    unit_cost             0.0
    association           :user
    association           :proxy
  end
end
