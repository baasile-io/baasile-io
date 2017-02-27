class CreateDocumentations < ActiveRecord::Migration[5.0]
  def change
    create_table :documentations do |t|
      t.integer :documentation_type, default: 1 # :root
      t.string :ancestry
      t.string :locale, null: false
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
