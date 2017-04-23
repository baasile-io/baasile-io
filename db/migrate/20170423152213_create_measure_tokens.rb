class CreateMeasureTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :measure_tokens do |t|
      t.string      :value
      t.string      :contract_status
      t.integer     :contract_id

      t.timestamps
    end
    add_index :measure_tokens, [:value, :contract_status, :contract_id], unique: true, name: 'value_status_contract_index'
  end
end
