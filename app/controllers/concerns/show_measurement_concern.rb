module ShowMeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :init_measurement, only: [:show], if: -> { !current_service.nil? }
  end

  def init_measurement
    @measures_output = Measurement.includes(:client, :route).by_startup(current_service)
    @measures_input = Measurement.includes(:service, :route).by_client(current_service)
  end

end

