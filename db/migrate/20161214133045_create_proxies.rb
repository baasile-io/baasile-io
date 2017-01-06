class CreateProxies < ActiveRecord::Migration[5.0]
  def change
    create_table :proxies do |t|
      t.string :name, limit: 255
      t.string :alias, limit: 25
      t.string :description

      t.belongs_to :service
      t.belongs_to :user

      t.timestamps
    end

    add_index :proxies, :name,                unique: true
  end
end
