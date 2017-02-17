class CreateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.string :title
      t.integer :client_id
      t.datetime :start_date
      t.datetime :end_date

      t.belongs_to :company
      t.belongs_to :service
      t.belongs_to :user

      t.timestamps
    end
  end
end
