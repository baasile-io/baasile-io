class AddLongDescStartup < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :description_long, :text, default: nil
  end
end
