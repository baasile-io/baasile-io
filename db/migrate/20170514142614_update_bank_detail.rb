class UpdateBankDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :client_bank_detail_id, :integer, index: true
    add_column :contracts, :startup_bank_detail_id, :integer, index: true
    remove_column :bank_details, :contract_id, :integer, index: true
  end
end
