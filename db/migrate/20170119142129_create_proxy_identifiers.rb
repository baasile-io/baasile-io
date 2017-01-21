class CreateProxyIdentifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :proxy_identifiers do |t|
      t.string :client_id
      t.string :encrypted_secret
      t.datetime :expires_at
      t.belongs_to :proxy
      t.belongs_to :user

      t.timestamps
    end
    add_index :proxy_identifiers, [:client_id, :encrypted_secret, :proxy_id], unique: true, name: 'index_proxy_identifiers_on_client_id_encrypted_secret_proxy_id'
  end
end
