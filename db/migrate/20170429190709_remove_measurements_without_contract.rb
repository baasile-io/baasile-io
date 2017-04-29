class RemoveMeasurementsWithoutContract < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        Measurement.where(contract_id: nil).destroy_all
      }
    end
  end
end
