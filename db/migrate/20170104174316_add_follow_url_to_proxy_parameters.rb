class AddFollowUrlToProxyParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :proxy_parameters, :follow_url, :boolean, default: false
    add_column :proxy_parameters, :follow_redirection, :integer, default: 10
  end
end
