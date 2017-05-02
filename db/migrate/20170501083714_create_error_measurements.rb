class CreateErrorMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :error_measurements do |t|
      t.string      :message
      t.integer     :error_type
      t.string      :request

      t.belongs_to  :contract
      t.belongs_to  :route

      t.timestamps
    end
  end
end
