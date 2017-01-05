FactoryGirl.define do
  factory :proxy_parameter do
    authentication_mode   :null
    protocol              :http
    hostname              'www.google.fr'
    port                  80
    client_id             'client_id'
    client_secret         'client_password'
    authentication_url    '/api/oauth/token'
  end
end