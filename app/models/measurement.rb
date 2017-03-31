class Measurement < ApplicationRecord

  belongs_to  :client, class_name: :Service
  belongs_to  :service
  belongs_to  :proxy
  belongs_to  :route

  scope :by_client, ->(client) { where(client_id: client.id).order(created_at: :desc) }
  scope :by_startup, ->(startup) { where(service_id: startup.id).order(created_at: :desc) }
  scope :by_proxy, ->(proxy) { where(proxy_id: proxy.id) }
  scope :by_route, ->(route) { where(route_id: route.id) }

  def increment_call
    self.requests_count += 1
  end

  class << self # Class methods
    def get_identical(contract, client, service, proxy, route, date_start, date_end)
      unless contract.nil?
        Measurement.where(contract_id: contract.id, client_id: client.id, service_id: service.id, proxy_id: proxy.id, route_id: route.id, created_at: date_start..date_end).first
      else
        Measurement.where(contract_id: nil, client_id: client.id, service_id: service.id, proxy_id: proxy.id, route_id: route.id, created_at: date_start..date_end).first
      end

    end
  end

end
