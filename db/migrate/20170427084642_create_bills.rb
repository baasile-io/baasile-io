class CreateBills < ActiveRecord::Migration[5.0]
  def change
    create_table :bills do |t|
      t.references :contract, foreign_key: true
      t.date :bill_month

      t.timestamps
    end
  end
end
