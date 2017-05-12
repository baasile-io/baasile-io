class UpdateErrorMeasurement < ActiveRecord::Migration[5.0]
  def self.up
    add_column :error_measurements, :response_http_status, :integer
    rename_column :error_measurements, :request, :request_detail
    change_column :error_measurements, :request_detail, :text
    rename_column :error_measurements, :status, :error_code
    remove_column :error_measurements, :message
  end

  def self.down
    remove_column :error_measurements, :response_http_status
    change_column :error_measurements, :request_detail, :string
    rename_column :error_measurements, :request_detail, :request
    rename_column :error_measurements, :error_code, :status
    add_column :error_measurements, :message, :string
  end
end
