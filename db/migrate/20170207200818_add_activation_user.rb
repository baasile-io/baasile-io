class AddActivationUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_active, :boolean, default: false
    User.update_all(is_active: true)
  end
end
