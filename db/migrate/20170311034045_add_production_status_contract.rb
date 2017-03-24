class AddProductionStatusContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :production, :boolean, default: false
  end
end
