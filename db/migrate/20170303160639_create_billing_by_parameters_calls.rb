class CreateBillingByParametersCalls < ActiveRecord::Migration[5.0]
  def change
    create_table :billing_by_parameters_calls do |t|
      t.string :name
      t.integer :billing_id
      t.string :parameter, default: nil
      t.integer :free_call, default: 0
      t.integer :periode_by_h_reset_free, default: nil
      t.decimal :cost_by_call, default: 0

      t.timestamps
    end
  end
end
