module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    after_action :do_request_measure_by_contract, only: [:process_request]
  end

  private

  def do_request_measure(contract, query_parameter, date_start, date_end)
    measure = Measurement.get_identical(contract, query_parameter, authenticated_service, current_service, current_proxy, current_route, date_start, date_end)
    if measure.nil?
      measure = Measurement.new(contract_id: contract.try(:id), query_parameter_id: query_parameter.try(:id), client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id)
    end
    measure.increment_call
    measure.save
  end

  def do_request_measure_by_contract
    contract = Contract.where( client: authenticated_service, startup: current_service, proxy: current_proxy).first
    date_start = Time.now.change(min: 0, sec: 0)
    date_end = date_start + 1.hour
    unless contract.nil?
      unless contract.price.nil? && contract.price.price_parameters.nil?
        @tab_headers = {}
        @res.header.each_header do |key,value|
          @tab_headers[key] = value
        end
        contract.price.price_parameters.each do |price_parameter|
          if @tab_headers.key?(price_parameter.query_parameter.name)
            do_request_measure(contract, price_parameter.query_parameter, date_start, date_end)
          end
        end
      else
        do_request_measure(contract, nil, date_start, date_end)
      end
    else
      do_request_measure(nil, nil, date_start, date_end)
    end
  end
end