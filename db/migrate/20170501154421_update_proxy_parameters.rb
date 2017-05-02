class UpdateProxyParameters < ActiveRecord::Migration[5.0]
  def change
    change_column_default :proxy_parameters, :authorization_mode, from: nil, to: 0
  end
end
