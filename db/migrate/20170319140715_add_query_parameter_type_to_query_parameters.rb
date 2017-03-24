class AddQueryParameterTypeToQueryParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :query_parameters, :query_parameter_type, :integer, default: 1
    add_column :query_parameters, :description, :string

    remove_index :query_parameters, [:name, :route_id]
    add_index :query_parameters, [:name, :query_parameter_type, :route_id], unique: true, name: 'name_query_parameter_type_route_index'
  end
end
