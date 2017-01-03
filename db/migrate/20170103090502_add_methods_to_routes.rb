class AddMethodsToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column      :routes, :allowed_methods, :text, array: true, default: []
  end
end
