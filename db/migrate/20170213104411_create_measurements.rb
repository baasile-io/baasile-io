class CreateMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :measurements do |t|
      t.integer :client_id, default: nil
      t.integer :requests_count, default: 0, null: false

      t.belongs_to  :service
      t.belongs_to  :proxy
      t.belongs_to  :route

      t.timestamps
    end
  end
end
