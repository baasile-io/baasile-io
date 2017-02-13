module ShowMeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :init_measurement, only: [:show], if: -> { !current_service.nil? }
  end

  def init_measurement
    @tabname = Hash.new
    @measures_service = Measurement.service(current_service)
    @measures_service.each do |service|
      @tabname[service.client_id] = Service.find(service.client_id)
    end
    @measures_client = Measurement.client(current_service)
    @measures_client.each do |client|
      @tabname[client.service_id] = Service.find(client.service_id)
    end
  end

end

