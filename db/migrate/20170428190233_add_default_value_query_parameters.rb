class AddDefaultValueQueryParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :query_parameters, :default_value, :string, default: nil
  end
end
