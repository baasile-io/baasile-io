class CreateTesterResults < ActiveRecord::Migration[5.0]
  def change
    create_table :tester_results do |t|
      t.integer :tester_request_id, index: true
      t.integer :route_id, index: true
      t.integer :proxy_id, index: true
      t.integer :service_id, index: true
      t.boolean :status
      t.text :error_message

      t.timestamps
    end
  end
end
