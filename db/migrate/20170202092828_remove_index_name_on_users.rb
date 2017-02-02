class RemoveIndexNameOnUsers < ActiveRecord::Migration[5.0]
  def change
    remove_index :proxies, :name
  end
end
