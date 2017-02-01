FactoryGirl.define do
  factory :contact_detail do
    contactable_type "MyString"
    contactable_id 1
    name "MyString"
    siret "MyString"
    address_line1 "MyString"
    address_line2 "MyString"
    address_line3 "MyString"
    zip "MyString"
    city "MyString"
    country "MyString"
    phone "MyString"
  end
end
