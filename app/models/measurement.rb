class Measurement < ApplicationRecord

  belongs_to  :client, class_name: :Service
  belongs_to  :service
  belongs_to  :proxy
  belongs_to  :route
  belongs_to  :contract
  belongs_to  :measure_token

  before_save :set_contract_status

  scope :by_contract_status, ->(contract) { where(contract: contract, contract_status: contract.status) }
  scope :by_client, ->(client) { where(client: client).order(created_at: :desc) }
  scope :by_startup, ->(startup) { where(service: startup).order(created_at: :desc) }
  scope :by_proxy, ->(proxy) { where(proxy: proxy) }
  scope :by_route, ->(route) { where(route: route) }
  scope :between, ->(start_date, end_date) { where('measurements.created_at BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date) }
  scope :last_week, -> {where('measurements.created_at >= ?', Date.today - 1.week)}
  scope :last_month, -> {where('measurements.created_at >= ?', Date.today - 1.month)}

  def increment_call
    self.requests_count += 1
  end

  class << self # Class methods
    def get_identical(client, service, proxy, route, date_start, date_end)
      Measurement.where(client_id: client.id, service_id: service.id, proxy_id: proxy.id, route_id: route.id, created_at: date_start..date_end).first
    end
  end

  def set_contract_status
    return self.contract_status = :validation if contract.nil?
    self.contract_status = self.contract.status.to_s
  end

end
