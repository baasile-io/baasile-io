class AddLockAttributeToPriceParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :price_parameters, :deny_after_free_count, :boolean, default: true
  end
end
