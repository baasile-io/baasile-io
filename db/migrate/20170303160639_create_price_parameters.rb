class CreatePriceParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :price_parameters do |t|
      t.string :name
      t.integer :price_parameters_type, default: 0
      t.string :parameter, default: nil
      t.integer :nb_free, default: 0
      t.integer :reset_free_perode_hour, default: nil
      t.decimal :cost, default: 0
      t.integer :user_id
      t.boolean :activate, default: true

      t.belongs_to :price

      t.timestamps
    end
  end
end
