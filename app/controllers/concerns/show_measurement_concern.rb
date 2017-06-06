module ShowMeasurementConcern
  extend ActiveSupport::Concern

  included do
    before_action :init_measurement, only: [:show], if: -> { !current_service.nil? }
  end

  def init_measurement
    service_ids = if current_service.service_type.to_sym == :company
                    current_service.subtree_ids
                  else
                    current_service.id
                  end

    @measures_output = Measurement.includes(:contract, :service, :proxy, :route, :measure_token).by_client(service_ids).order(created_at: :asc)
    @measures_input = Measurement.includes(:contract, :client, :proxy, :route, :measure_token).by_startup(service_ids).order(created_at: :asc)
  end

end
