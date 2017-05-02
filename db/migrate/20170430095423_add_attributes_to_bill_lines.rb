class AddAttributesToBillLines < ActiveRecord::Migration[5.0]
  def change
    add_column :bill_lines, :line_type, :integer, default: 0
    add_column :bill_lines, :vat_rate, :numeric, default: 0.0
    add_column :bill_lines, :total_cost, :numeric, default: 0.0
    add_column :bill_lines, :total_cost_including_vat, :numeric, default: 0.0

    change_column :bill_lines, :unit_cost, :numeric, default: 0.0
    change_column :bill_lines, :unit_num, :integer, default: 0

    add_column :bills, :total_cost, :numeric, default: 0.0
    add_column :bills, :total_vat, :numeric, default: 0.0
    add_column :bills, :total_cost_including_vat, :numeric, default: 0.0
  end
end
