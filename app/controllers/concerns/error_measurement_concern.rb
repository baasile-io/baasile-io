module ErrorMeasurementConcern
  extend ActiveSupport::Concern

  private

  def do_request_error_measure(error, request_detail)
    begin
      error_measurement = ErrorMeasurement.create!(
        client: authenticated_service,
        contract: current_contract,
        route: current_route,
        error_type: error.class.name,
        error_code: error.code,
        response_http_status: (!error.res.nil? ? error.res.code : 0),
        request_detail: request_detail.to_json
      )

      # send email notifications
      notified_users_ids = []
      [authenticated_service, current_route.service].each do |service|
        service.users.each do |user|
          if !notified_users_ids.include?(user.id) && user.is_developer_of?(service)
            ErrorMeasurementNotifier.send_error_measurement_notification(error_measurement, user).deliver_now
          end
          notified_users_ids << user.id
        end
      end

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