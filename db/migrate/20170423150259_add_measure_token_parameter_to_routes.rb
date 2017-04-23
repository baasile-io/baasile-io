class AddMeasureTokenParameterToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :measure_token_activated, :boolean, default: false
  end
end
