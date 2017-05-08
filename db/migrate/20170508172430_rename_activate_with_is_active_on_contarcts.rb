class RenameActivateWithIsActiveOnContarcts < ActiveRecord::Migration[5.0]
  def change
    rename_column :contracts, :activate, :is_active
  end
end
