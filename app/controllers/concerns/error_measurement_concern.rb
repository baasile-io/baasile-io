module ErrorMeasurementConcern
  extend ActiveSupport::Concern

  private

  def do_request_error_measure(error, request_detail)
    measure = ErrorMeasurement.create!(
      contract: current_contract,
      route: current_route,
      error_type: error.class.name,
      error_code: error.code,
      response_http_status: error.http_status,
      request_detail: request_detail.to_json
    )
    ErrorMeasurementNotifier.send_error_measurement_notification(measure).deliver_now
    true
  rescue
    false
  end

end