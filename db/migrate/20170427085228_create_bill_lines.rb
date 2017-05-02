class CreateBillLines < ActiveRecord::Migration[5.0]
  def change
    create_table :bill_lines do |t|
      t.references :bill, foreign_key: true
      t.string :title
      t.decimal :unit_cost
      t.integer :unit_num

      t.timestamps
    end
  end
end
