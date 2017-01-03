FactoryGirl.define do
  factory :route do
    sequence(:name)         {|i| "Route #{i}"}
    description             "Description"
    allowed_methods         Route::ALLOWED_METHODS

    association             :proxy
    association             :user
  end
end
