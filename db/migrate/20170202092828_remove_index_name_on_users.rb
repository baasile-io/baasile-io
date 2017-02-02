class RemoveIndexNameOnUsers < ActiveRecord::Migration[5.0]
  def change
    remove_index :proxies, 'index_proxies_on_name'
  end
end
