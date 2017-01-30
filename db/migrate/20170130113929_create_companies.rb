class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.integer :parent_id
      t.integer :uuid
      t.string :name, limit: 255
      t.integer :administrator_id
      t.integer :contact_detail_id
      t.integer :user_id

      t.timestamps
    end

    add_index :companies, :name,                unique: true
  end
end
