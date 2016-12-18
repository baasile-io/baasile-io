class CreateFunctionalities < ActiveRecord::Migration[5.0]
  def change
    create_table :functionalities do |t|
      t.string :name, limit: 255
      t.string :description
      t.integer :type
      t.integer :service_id
      t.integer :user_id

      t.timestamps
    end
  end
end
