class CreateQueryParameters < ActiveRecord::Migration[5.0]

  def change
    create_table :query_parameters do |t|
      t.string :name
      t.integer :mode, default: :optional
      t.belongs_to :route
      t.belongs_to  :user

      t.timestamps
    end
    add_index :query_parameters, [:name, :route_id],                unique: true
  end
end
