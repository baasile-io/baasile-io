FactoryGirl.define do
  factory :proxy_parameter do
    authorization_mode   :null
    protocol              :http
    hostname              'www.google.fr'
    port                  80
    follow_url            false
    follow_redirection    10
  end
end
