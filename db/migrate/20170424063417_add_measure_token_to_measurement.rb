class AddMeasureTokenToMeasurement < ActiveRecord::Migration[5.0]
  def change
    rename_column :measurements, :query_parameter_id, :measure_token_id
  end
end
