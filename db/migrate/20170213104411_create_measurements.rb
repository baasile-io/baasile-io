class CreateMeasurements < ActiveRecord::Migration[5.0]
  def change
    create_table :measurements do |t|
      t.integer :client_id, default: 0, null: false
      t.integer :service_id, default: 0, null: false
      t.integer :proxy_id, default: 0, null: false
      t.integer :route_id, default: 0, null: false
      t.integer :number_call, default: 0, null: false
      t.datetime :first_call_at, default: nil
      t.datetime :last_call_at, default: nil

      t.timestamps
    end
  end
end
