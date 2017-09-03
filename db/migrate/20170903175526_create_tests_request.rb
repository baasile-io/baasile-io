class CreateTestsRequest < ActiveRecord::Migration[5.0]
  def change
    create_table :tests_requests do |t|
      t.belongs_to :user
      t.belongs_to :route
      t.boolean :is_test_settings
      t.string :method
      t.string :uri
      t.string :format

      t.timestamps
    end
  end
end
