class AddActivationUserDefaultFalse < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :is_active, :boolean, default: false
  end
end
