class AddContractStatusToMeasurements < ActiveRecord::Migration[5.0]
  def change
    add_column :measurements, :contract_status, :string
  end
end
