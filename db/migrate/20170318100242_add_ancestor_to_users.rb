class AddAncestorToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ancestry, :string
    add_index :users, :ancestry
  end
end
