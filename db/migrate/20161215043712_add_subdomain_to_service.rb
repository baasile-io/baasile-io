class AddSubdomainToService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :subdomain, :string
  end
end
