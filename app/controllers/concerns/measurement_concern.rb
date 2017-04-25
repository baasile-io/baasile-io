module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :load_measure_token, only: [:process_request]
    after_action :do_request_measure, only: [:process_request]
  end

  private

  def do_request_measure
    date_start = DateTime.now.change(hour: 0, min: 0, sec: 0)
    measure = Measurement.where(contract: current_contract, client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id, created_at: date_start, measure_token_id: current_measure_token.try(:id)).first_or_create!
    measure.increment_call
    measure.save!
  end

  def load_measure_token
    return if current_contract_pricing_type != :per_parameter

    given_measure_token_value = request.headers[Appconfig.get(:api_measure_token_name)]
    @measure_token = measure_token_first_or_create(given_measure_token_value)
    response.headers[Appconfig.get(:api_measure_token_name)] = @measure_token.value
  end

  def current_measure_token
    @measure_token
  end

  def measure_token_first_or_create(value)
    MeasureToken.where(value: value, contract: current_contract, contract_status: current_contract_status).first_or_create!
  end
end