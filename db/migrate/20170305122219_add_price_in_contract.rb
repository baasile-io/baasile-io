class AddPriceInContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :price_id, :integer, default: nil
  end
end
