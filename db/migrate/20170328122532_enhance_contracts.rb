class EnhanceContracts < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :contract_duration, :integer
    add_column :contracts, :expected_start_date, :date
    add_column :contracts, :expected_end_date, :date
    add_column :contracts, :expected_contract_duration, :integer, default: 1
    add_column :contracts, :is_evergreen, :boolean, default: false
  end
end
