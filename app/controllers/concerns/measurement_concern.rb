module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    after_action :do_request_measure, only: [:process_request]
  end

  private

  def do_request_measure
    date_start = Time.now.change(min: 0, sec: 0)
    date_end = date_start + 1.hour

    measure = Measurement.get_identical(authenticated_service, current_service, current_proxy, current_route, date_start, date_end)
    if measure.nil?
      measure = Measurement.new(client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id)
    end
    measure.increment_call
    measure.save
  end

  def check_create_token(token, contract)
    return false unless check_measure_token_error(token, contract)
    measure_token = MeasureToken.new(value: token, contract: contract, contract_status: contract.status)
    if token.blank? || !measure_token.already_exist?
      measure_token.generate_token
      measure_token.save
    end
    return true
  end

  def check_measure_token_error(token, contract)
    return true if !contract.nil? && ( !MeasureToken.by_token(token).nil? || token.blank?)
    return false
  end

end