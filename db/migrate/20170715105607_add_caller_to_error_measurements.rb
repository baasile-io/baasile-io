class AddCallerToErrorMeasurements < ActiveRecord::Migration[5.0]
  def change
    add_column :error_measurements, :client_id, :integer

    reversible do |direction|
      direction.up {
        ErrorMeasurement.includes(:contract, :proxy).all.each do |error_measurement|
          error_measurement.update!(
            client_id: (error_measurement.contract.nil? ? error_measurement.proxy.service_id : error_measurement.contract.client_id)
          )
        end
      }
    end
  end
end
