class ChangeContractAndPriceAssociation < ActiveRecord::Migration[5.0]
  def change
    remove_column :contracts, :price_id, :integer
    remove_column :prices, :attached, :boolean
    add_column :prices, :contract_id, :integer
    add_index :prices, :contract_id
  end
end
