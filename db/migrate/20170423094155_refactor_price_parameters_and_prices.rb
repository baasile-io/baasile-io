class RefactorPriceParametersAndPrices < ActiveRecord::Migration[5.0]
  def change
    rename_column :prices, :cost_by_time, :cost
    add_column :prices, :pricing_duration_type, :integer, default: 0
    add_column :prices, :pricing_type, :integer, default: 0
    add_column :prices, :free_count, :integer, default: 0
    add_column :prices, :deny_after_free_count, :boolean, default: true
    add_column :prices, :unit_cost, :numeric, default: 0.0
    add_reference :prices, :route, index: true
    add_reference :prices, :query_parameter, index: true
  end
end
