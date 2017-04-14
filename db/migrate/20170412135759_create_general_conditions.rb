class CreateGeneralConditions < ActiveRecord::Migration[5.0]
  def change
    create_table :general_conditions do |t|
      t.integer   :user_id
      t.string    :cg_version
      t.date      :effective_start_date

      t.timestamps
    end
  end
end
