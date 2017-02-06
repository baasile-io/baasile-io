class AddKindOfService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :kind_of, :integer, default: 1
  end
end
