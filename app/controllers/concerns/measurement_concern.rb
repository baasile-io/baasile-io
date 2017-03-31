module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    #after_action :do_request_measure, only: [:process_request]
    after_action :do_request_measure_by_contract, only: [:process_request]
  end

  private

  def do_request_measure
    date_start = Time.now.change(min: 0, sec: 0)
    date_end = date_start + 1.hour

    measure = Measurement.get_identical(nil, authenticated_service, current_service, current_proxy, current_route, date_start, date_end)
    if measure.nil?
      measure = Measurement.new(client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id)
    end
    measure.increment_call
    measure.save
  end

  def do_request_measure_by_contract
    contracts = Contract.where( client: authenticated_service, startup: current_service, proxy: current_proxy)

    if contracts.count == 1
      contract = contracts.first
    end

    contract.price.price_parameters.each do |price_parameter|
      logger.info "check: " + price_parameter.query_parameter.name.inspect
      if @tab_headers.key?(price_parameter.query_parameter.name)
        #todo make hash parameters match
      end
    end

    date_start = Time.now.change(min: 0, sec: 0)
    date_end = date_start + 1.hour

    measure = Measurement.get_identical(contract, authenticated_service, current_service, current_proxy, current_route, date_start, date_end)
    if measure.nil?
      measure = Measurement.new(contract_id: contract.id, client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id)
    end
    measure.increment_call
    measure.save
  end

end