module ErrorMeasurementConcern
  extend ActiveSupport::Concern

  private

  def do_request_error_measure(error_type, status, request, message = nil)
    ErrorMeasurement.create!(
      contract: current_contract,
      route: current_route,
      status: status,
      error_type: error_type,
      request: request,
      message: message
    )
    ErrorMeasurementNotifier.send_error_measurement_notification(measure).deliver_now
    true
  rescue
    false
  end
end