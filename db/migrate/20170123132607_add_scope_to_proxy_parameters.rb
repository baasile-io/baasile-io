class AddScopeToProxyParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :proxy_parameters, :scope, :string
  end
end
