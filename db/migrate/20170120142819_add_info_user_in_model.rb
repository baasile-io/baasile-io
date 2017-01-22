class AddInfoUserInModel < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :first_name, :string, null: true
    add_column :users, :last_name, :string, null: true
    add_column :users, :gender, :integer, null: true
    add_column :users, :phone, :string, null: true
  end
end
