class AddContractTypeToContracts < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :contract_duration_type, :integer, default: 0
  end
end
