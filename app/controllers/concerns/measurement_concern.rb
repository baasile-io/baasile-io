module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :authorize_measured_request, only: [:process_request]
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
    return unless current_contract_pricing_type == :per_parameter && current_route.measure_token_activated

    given_measure_token_value = request.headers[Appconfig.get(:api_measure_token_name)]

    if given_measure_token_value.blank?
      create_measure_token
    else
      find_measure_token(given_measure_token_value)
      if @measure_token.nil?
        return render status: 403, json: {
          errors: [{
                     status: 403,
                     title: "Invalid #{Appconfig.get(:api_measure_token_name)}"
                   }]
        }
      end
    end

    response.headers[Appconfig.get(:api_measure_token_name)] = @measure_token.value
  end

  def authorize_measured_request
    return if current_contract_price_request_limit == false

    measurements = Measurement.by_contract_status(current_contract)

    case current_contract_pricing_duration_type
      when :monthly
        measurements = measurements.where('created_at >= :start AND created_at <= :end', start: today.beginning_of_month, end: today.end_of_month)
      when :yearly
        measurements = measurements.where('created_at >= :start AND created_at <= :end', start: today.beginning_of_year, end: today.end_of_year)
    end

    requests_count = case current_contract_pricing_type
                       when :per_call
                         measurements.sum(:requests_count)
                       when :per_parameter
                         measurements.select(:measure_token_id).distinct.count
                     end

    if requests_count >= current_contract_price_request_limit
      return render status: 403, json: {
        errors: [{
                   status: 403,
                   title: 'Subscription limit is reached.'
                 }]
      }
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