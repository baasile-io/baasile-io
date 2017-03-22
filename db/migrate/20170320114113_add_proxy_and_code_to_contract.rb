class AddProxyAndCodeToContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :proxy_id, :integer, default: nil
    add_column :contracts, :code, :string, default: nil

    add_index :contracts, [:client_id, :startup_id, :proxy_id], unique: true
  end
end
