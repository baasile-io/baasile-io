class AddFieldsToBills < ActiveRecord::Migration[5.0]
  def change
    add_column :bills, :start_date, :date
    add_column :bills, :end_date,   :date
    add_column :bills, :duration,   :integer
  end
end
