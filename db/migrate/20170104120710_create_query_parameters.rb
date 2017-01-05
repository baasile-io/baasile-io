class CreateQueryParameters < ActiveRecord::Migration[5.0]

  def change
    create_table :query_parameters do |t|
      t.string :name
      t.integer :mode
      t.belongs_to :route

      t.timestamps
    end
    add_index :query_parameters, :name,                unique: true
  end
end
