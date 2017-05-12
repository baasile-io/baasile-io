class UpdateContractAttributes < ActiveRecord::Migration[5.0]
  def change
    rename_column :contracts, :code, :client_code
    add_column :contracts, :startup_code, :string
    remove_column :contracts, :name, :string
  end
end
