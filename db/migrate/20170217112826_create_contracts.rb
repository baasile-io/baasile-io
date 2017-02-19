class CreateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.belongs_to :client, class_name: "Service"
      t.belongs_to :company
      t.belongs_to :startup, class_name: "Service"
      t.belongs_to :user

      t.timestamps
    end
  end
end
