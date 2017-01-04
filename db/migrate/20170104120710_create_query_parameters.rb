class CreateQueryParameters < ActiveRecord::Migration[5.0]
  def change
    create_table :query_parameters do |t|
      t.string :name
      t.string :mode
      t.belongs_to :route
      t.belongs_to  :user

      t.timestamps
    end
  end
end
