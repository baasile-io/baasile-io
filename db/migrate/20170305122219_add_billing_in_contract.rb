class AddBillingInContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :billing_id, :integer, default: nil
  end
end
