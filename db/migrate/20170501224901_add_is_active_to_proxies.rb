class AddIsActiveToProxies < ActiveRecord::Migration[5.0]
  def change
    add_column :proxies, :is_active, :boolean, default: true
  end
end
