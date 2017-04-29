FactoryGirl.define do
  factory :proxy_parameter do
    authorization_mode   :null
    protocol              :http
    sequence(:hostname)   {|i| "www.google.#{['fr', 'com', 'es', 'it'].at(i % 4)}"}
    port                  80
    follow_url            false
    follow_redirection    10
  end
end
