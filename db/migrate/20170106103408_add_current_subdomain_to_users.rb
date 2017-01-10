class AddCurrentSubdomainToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :current_subdomain, :string, null: true
  end
end
