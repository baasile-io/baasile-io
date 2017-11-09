class CreateTesterRequest < ActiveRecord::Migration[5.0]
  def change
    create_table :tester_requests do |t|
      t.string :type, null: false
      t.string :name
      t.belongs_to :user
      t.belongs_to :route
      t.belongs_to :category
      t.boolean :use_authorization, default: true
      t.string :method
      t.string :uri
      t.string :format
      t.string :follow_url
      t.text :request_body

      t.timestamps
    end
  end
end
