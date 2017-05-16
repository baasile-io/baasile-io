class AddSampleValueToQueryParameters < ActiveRecord::Migration[5.0]
  def change
    add_column :query_parameters, :sample_value, :text
  end
end
