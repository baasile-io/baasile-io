class AddActivationAndSignContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :activate, :boolean, default: true
    add_column :contracts, :status, :integer, default: 0

    add_index :contracts, [:client_id, :startup_id], unique: true
  end

end
