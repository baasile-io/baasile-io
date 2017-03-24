class CreatePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :prices do |t|
      t.string :name
      t.decimal :base_cost, default: 0
      t.decimal :cost_by_time, default: 0
      t.integer :user_id
      t.boolean :activate, default: true
      t.boolean :attached, default: false

      t.belongs_to :proxy
      t.belongs_to :service

      t.timestamps
    end
  end
end
