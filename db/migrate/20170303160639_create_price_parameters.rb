class CreatePriceParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :price_parameters do |t|
      t.string :name
      t.integer :price_parameters_type, default: 1
      t.string :parameter, default: nil
      t.decimal :cost, default: 0
      t.integer :user_id
      t.boolean :activate, default: true
      t.boolean :attached, default: false

      t.belongs_to :price

      t.timestamps
    end
  end
end
