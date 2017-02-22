class AddActivationAndSignContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :activate, :boolean, default: false
    add_column :contracts, :client_status, :integer, default: 0
    add_column :contracts, :startup_status, :integer, default: 0
    add_column :contracts, :company_status, :integer, default: nil

    add_index :contracts, [:client_id, :startup_id], unique: true
  end

end
