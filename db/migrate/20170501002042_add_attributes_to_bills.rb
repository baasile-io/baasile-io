class AddAttributesToBills < ActiveRecord::Migration[5.0]
  def change
    add_column :bills, :due_date, :date
    add_column :bills, :paid, :boolean, default: false
    add_column :bills, :platform_contribution_rate, :numeric, default: 0.0

    add_index :bills, [:contract_id, :bill_month], unique: true
  end
end
