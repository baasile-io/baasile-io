class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :description
      t.integer :user_id

      t.timestamps
    end

    add_index :categories, :name, unique: true
  end
end
