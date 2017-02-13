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

end