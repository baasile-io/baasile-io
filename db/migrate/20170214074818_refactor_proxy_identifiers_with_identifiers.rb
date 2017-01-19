class RefactorProxyIdentifiersWithIdentifiers < ActiveRecord::Migration[5.0]
  def change
    rename_table :proxy_identifiers, :identifiers

    rename_column :proxy_parameters, :authentication_mode, :authorization_mode
    rename_column :proxy_parameters, :authentication_url, :authorization_url

    add_column :identifiers, :identifiable_type, :string
    add_column :identifiers, :identifiable_id, :integer
    add_index :identifiers, [:identifiable_type, :identifiable_id], name: 'identifiable_type_id'
    add_index :identifiers, [:identifiable_type, :identifiable_id, :client_id], unique: true, name: 'identifiable_type_id_client_id'

    reversible do |direction|
      direction.up {
        remove_column :identifiers, :proxy_id
        remove_column :identifiers, :user_id

        Proxy.all.each do |proxy|
          unless proxy.proxy_parameter.nil?
            if proxy.proxy_parameter.authorization_required? && proxy.proxy_parameter.client_id
              proxy.proxy_parameter.build_identifier
              proxy.proxy_parameter.identifier.client_id = proxy.proxy_parameter.client_id
              proxy.proxy_parameter.identifier.client_secret = proxy.proxy_parameter.client_secret
              proxy.proxy_parameter.identifier.save!
            end
          end
        end

        remove_column :proxy_parameters, :client_id
        remove_column :proxy_parameters, :client_secret
      }
      direction.down {
        add_column :identifiers, :proxy_id, :integer
        add_column :identifiers, :user_id, :integer
        add_column :proxy_parameters, :client_id, :string
        add_column :proxy_parameters, :client_secret, :string
      }
    end
  end
end
