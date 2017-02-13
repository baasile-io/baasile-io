class Measurement < ApplicationRecord

  scope :client, ->(client) { where(client_id: client.id) }
  scope :service, ->(service) { where(service_id: service.id) }
  scope :proxy, ->(proxy) { where(proxy_id: proxy.id) }
  scope :route, ->(route) { where(route_id: route.id) }

  scope :identical, ->(client, service, proxy, route, date_start, date_end) { where(client_id: client.id, service_id: service.id,
                                                              proxy_id: proxy.id, route_id: route.id, first_call_at: date_start..date_end ) }

  def increment_call
    self.number_call += 1
  end

end
