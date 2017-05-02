FactoryGirl.define do
  factory :bill_line do
    bill nil
    title "MyString"
    unit_cost "9.99"
    unit_num 1
  end
end
