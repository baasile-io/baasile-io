class CreateRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.string      :name
      t.string      :description
      t.integer     :protocol
      t.string      :hostname
      t.string      :port
      t.string      :url

      t.belongs_to  :proxy
      t.belongs_to  :user

      t.timestamps
    end
    add_index :routes, :name,                unique: true
  end
end
