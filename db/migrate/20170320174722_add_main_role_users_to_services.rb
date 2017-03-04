class AddMainRoleUsersToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :main_commercial_id, :integer
    add_column :services, :main_developer_id, :integer
    add_column :services, :main_accountant_id, :integer

    add_index :services, :main_commercial_id
    add_index :services, :main_developer_id
    add_index :services, :main_accountant_id
  end
end
