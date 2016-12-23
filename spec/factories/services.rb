FactoryGirl.define do
  factory :service do
    sequence(:name)       {|i| "My Service (#{i})"}
    description           'My Description'
    association           :user
    sequence(:subdomain)  {|i| "service#{i}"}
    sequence(:client_id)  {|i| "2d931510-#{i.to_s.rjust(4, '0')}-494a-8c67-87feb05e1594"}
    client_secret         'abcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghjikabcdefghj'

    factory :service_not_activated do
      confirmed_at        nil
      subdomain           nil
    end

    after(:create) do |service|
      if service.subdomain.present?
        Apartment::Tenant.create(service.subdomain)
        service.confirmed_at = Date.new
        service.save
      end
    end
  end
end
