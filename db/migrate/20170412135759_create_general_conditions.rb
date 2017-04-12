class CreateGeneralConditions < ActiveRecord::Migration[5.0]
  def change
    create_table :general_conditions do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
