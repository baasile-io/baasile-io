class AddLongDescriptionToProxies < ActiveRecord::Migration[5.0]
  def change
    add_column :proxies, :description_long, :text
  end
end
