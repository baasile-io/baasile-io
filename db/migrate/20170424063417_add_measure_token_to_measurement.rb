class AddMeasureTokenToMeasurement < ActiveRecord::Migration[5.0]
  def change
    add_column :measurements, :measure_token_id, :integer
  end
end
