class CreateProxyIdentifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :proxy_identifiers do |t|
      t.string :client_id
      t.string :encrypted_secret
      t.belongs_to :proxy
      t.belongs_to :user

      t.timestamps
    end
    add_index :proxy_identifiers, [:client_id, :encrypted_secret], unique: true
  end
end
