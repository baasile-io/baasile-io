module MeasurementConcern
  extend ActiveSupport::Concern
  
  class ProxyCanceledMeasurement < StandardError
    attr_reader :error, :request_detail, :meta

    def initialize(data)
      data ||= {}
      @error = data[:error]
      @request_detail = data[:request_detail]
      @meta = data[:meta]
    end
  end

  included do
    before_action :authorize_measured_request, only: [:process_request]
    before_action :load_measure_token, only: [:process_request]
    around_action :do_request_measure, only: [:process_request]
  end

  private

  def do_request_measure
    Measurement.transaction do
      date_start = DateTime.now.change(hour: 0, min: 0, sec: 0)
      measure = Measurement.where(contract: current_contract, client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id, created_at: date_start, measure_token_id: current_measure_token.try(:id)).first_or_create!
      measure.increment_call
      measure.save!
      yield
      unless @measure_token.nil?
        response.headers[Appconfig.get(:api_measure_token_name)] = @measure_token.value
      end
    end
  rescue ProxyCanceledMeasurement => e
    do_request_error_measure(e.error, e.request_detail)
    raise e.error.class, {req: e.error.req, res: e.error.res, uri: e.error.uri, message: e.error.message, meta: e.meta}
  end

  def load_measure_token
    return unless current_contract_pricing_type == :per_parameter && current_route.measure_token_activated

    given_measure_token_value = request.headers[Appconfig.get(:api_measure_token_name)]

    if given_measure_token_value.blank?
      create_measure_token
    else
      find_measure_token(given_measure_token_value)
      if @measure_token.nil?
        error = Api::MeasureTokenNotFoundError.new
        do_request_error_measure(error, nil)
        raise error
      end
      if @measure_token.revoked
        error = Api::MeasureTokenRevokedError.new
        do_request_error_measure(error, nil)
        raise error
      end
    end
  end

  def authorize_measured_request
    unless Contracts::ContractCheckFreeCountLimit.new(current_contract, current_route).call
      error = Api::ContractFreeCountLimitReached.new
      do_request_error_measure(error, nil)
      raise error
    end
  end

  def current_measure_token
    @measure_token
  end

  def today
    @today ||= Date.today
  end

  def find_measure_token(value)
    @measure_token = MeasureToken.where(value: value, contract: current_contract, contract_status: current_contract_status).first
  end

  def create_measure_token
    @measure_token = MeasureToken.create!(contract: current_contract, contract_status: current_contract_status)
  end
end