class CreateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.integer :client_id, :integer, null: true
      t.integer :company_id, :integer, null: true
      t.integer :startup_id, :integer, null: true
      t.integer :user_id

      t.timestamps
    end
  end
end
