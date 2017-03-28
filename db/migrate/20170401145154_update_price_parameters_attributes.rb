class UpdatePriceParametersAttributes < ActiveRecord::Migration[5.0]
  def change
    change_column :price_parameters, :free_count, :integer, default: 0
  end
end
