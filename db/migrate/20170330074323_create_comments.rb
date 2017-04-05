class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.belongs_to :commentable, polymorphic: true
      t.belongs_to :user
      t.text :body
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
