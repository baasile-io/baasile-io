class AddKindOfService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :service_type, :integer, default: 1
  end
end
