class RemoveIndexNameOnRoutes < ActiveRecord::Migration[5.0]
  def change
    remove_index :routes, :name
  end
end
