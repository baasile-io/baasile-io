class AddStatusToErrorMeasurement < ActiveRecord::Migration[5.0]
  def self.up
    add_column :error_measurements, :status, :integer
    change_column :error_measurements, :error_type, :string
  end

  def self.down
    remove_column :error_measurements, :status
    change_column :error_measurements, :error_type, :integer
  end
end
