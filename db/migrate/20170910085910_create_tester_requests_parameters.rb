class CreateTesterRequestsParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :tester_parameters do |t|
      t.string :type, null: false
      t.belongs_to :tester_request
      t.string :name
      t.string :value
    end
  end
end
