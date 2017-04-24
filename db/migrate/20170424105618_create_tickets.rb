class CreateTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :tickets do |t|
      t.string  :subject
      t.integer :ticket_type
      t.integer :ticket_status

      t.belongs_to  :user
      t.belongs_to  :service

      t.timestamps
    end
  end
end
