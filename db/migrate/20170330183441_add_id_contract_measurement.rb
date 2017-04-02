class AddIdContractMeasurement < ActiveRecord::Migration[5.0]
  def change
    add_column :measurements, :contract_id, :integer, default: nil
    add_column :measurements, :query_parameter_id, :integer, default: nil
  end
end
