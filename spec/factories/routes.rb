FactoryGirl.define do
  factory :route do
    sequence(:name)         {|i| "Route #{i}"}
    sequence(:subdomain)    {|i| "route#{i}"}
    description             "Description"
    allowed_methods         Route::ALLOWED_METHODS
    url                     '/'

    association             :proxy
    association             :user
  end
end
