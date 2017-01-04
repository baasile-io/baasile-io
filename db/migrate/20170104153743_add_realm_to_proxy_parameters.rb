class AddRealmToProxyParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :proxy_parameters, :realm, :string
    add_column :proxy_parameters, :grant_type, :string
  end
end
