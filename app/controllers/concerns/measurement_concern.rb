module MeasurementConcern
  extend ActiveSupport::Concern

  included do
    after_action :do_request_measure, only: [:process_request], if: -> { @request_sucess }
    after_action :log_mesure, only: [:process_request], if: -> { @request_sucess }
  end

  private

  def do_request_measure
    date_start = Time.now.change(min: 0, sec: 0)
    date_end = date_start + 1.hour

    measure = Measurement.identical(authenticated_service, current_service, current_proxy, current_route, date_start, date_end)
    measure = measure[0]
    if measure.nil?
      measure = Measurement.new(client_id: authenticated_service.id, service_id: current_service.id, proxy_id: current_proxy.id, route_id: current_route.id, first_call_at: Time.now )
    end
    measure.increment_call
    measure.save
  end

  def log_mesure
    measures = Measurement.client(authenticated_service)
    measures.each do |measure|
      info_date_start = measure.first_call_at.change(min: 0, sec: 0)
      info_date_end = info_date_start + 1.hour
      number_call = measure.number_call
      logger.info "#########@ date start @############"
      logger.info info_date_start.inspect
      logger.info "#########@ date end @############"
      logger.info info_date_end.inspect
      logger.info "#########@ number call @############"
      logger.info number_call.inspect
      logger.info "#########@@############"
    end
  end

end