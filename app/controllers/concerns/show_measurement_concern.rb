module ShowMeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :init_measurement, only: [:show], if: -> { !current_service.nil? }
  end

  def init_measurement
    @measures_output = Measurement.includes(:contract, :client, :proxy, :route, :measure_token).by_startup(current_service)
    @measures_input = Measurement.includes(:contract, :service, :proxy, :route, :measure_token).by_client(current_service)
  end

end
