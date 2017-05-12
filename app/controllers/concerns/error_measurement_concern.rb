module ErrorMeasurementConcern
  extend ActiveSupport::Concern

  private

  def do_request_error_measure(error, request_detail)
    begin
      measure = ErrorMeasurement.create!(
        contract: current_contract,
        route: current_route,
        error_type: error.class.name,
        error_code: error.code,
        response_http_status: (!error.res.nil? ? error.res.code : 0),
        request_detail: request_detail.to_json
      )
      ErrorMeasurementNotifier.send_error_measurement_notification(measure, error.notifications).deliver_now
      true
    rescue Exception => e
      Rails.logger.error "Failed to measure error #{e.class} #{e.message}"
      Airbrake.notify('Failed to measure error', {
        error: e.class,
        message: e.message
      })
      false
    end
  end

end