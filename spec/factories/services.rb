FactoryGirl.define do
  factory :service do
    sequence(:name)       {|i| "My Service (#{i})"}
    description           'My Description'
    association           :user
    sequence(:subdomain)  {|i| "service#{i}"}
    sequence(:client_id)  {|i| "2d931510-#{i.to_s.rjust(4, '0')}-494a-8c67-87feb05e1594"}
    client_secret         'abcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghj'
    confirmed_at          Date.new

    factory :client_service do
      service_type          :client
    end

    factory :startup_service do
      service_type          :client
    end
  end

  factory :service_not_activated, class: Service do
    sequence(:name)       {|i| "My Service Not Activated (#{i})"}
    description           'My Description'
    association           :user
    sequence(:client_id)  {|i| "2e931510-#{i.to_s.rjust(4, '0')}-494a-8c67-87feb05e1594"}
    client_secret         'abcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghj'
    confirmed_at          nil
    sequence(:subdomain)  {|i| "notactiveservice#{i}"}
  end
end
