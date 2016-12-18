class CreateProxyParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :proxy_parameters do |t|
      t.integer     :protocol
      t.string      :hostname
      t.integer     :port
      t.string      :authentication_url
      t.integer     :authentication_mode
      t.string      :client_id
      t.string      :client_secret

      t.timestamps
    end

    add_column :functionalities, :proxy_parameter_id, :integer, null: true
  end
end
