class AddAttributesToContracts < ActiveRecord::Migration[5.0]
  def change
    remove_column :contracts, :contract_duration_type
    add_column :contracts, :expected_free_count, :integer
  end
end
