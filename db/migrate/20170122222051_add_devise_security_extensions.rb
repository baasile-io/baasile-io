class AddDeviseSecurityExtensions < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :password_changed_at, :datetime
    add_column :users, :unique_session_id, :string, limit: 20
    add_column :users, :last_activity_at, :datetime
    add_column :users, :expired_at, :datetime

    create_table :old_passwords do |t|
      t.string :encrypted_password, null: false
      t.string :password_archivable_type, null: false
      t.integer :password_archivable_id, null: false
      t.datetime :created_at
    end

    add_index :users, :password_changed_at
    add_index :users, :expired_at
    add_index :users, :last_activity_at
    add_index :old_passwords, [:password_archivable_type, :password_archivable_id], :name => :index_password_archivable
  end
end
