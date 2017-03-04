class CreateBillings < ActiveRecord::Migration[5.0]
  def change
    create_table :billings do |t|
      t.string :name
      t.decimal :base_cost, default: 0
      t.integer :free_hour, default: 0
      t.decimal :cost_by_time, default: 0
      t.integer :user_id
      t.boolean :activate, default: true

      t.belongs_to :service

      t.timestamps
    end
  end
end
