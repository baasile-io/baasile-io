class CreateDictionaries < ActiveRecord::Migration[5.0]
  def change
    create_table :dictionaries do |t|
      t.belongs_to :localizable, polymorphic: true, index: false
      t.string :locale, default: 'fr'
      t.text :title
      t.text :subtitle
      t.text :body
      t.text :footer

      t.timestamps
    end

    add_index :dictionaries, [:localizable_type, :localizable_id, :locale], name: 'index_on_localizable_and_locale'

    add_column :documentations, :public, :boolean, default: false

    remove_column :documentations, :title
    remove_column :documentations, :body
    remove_column :documentations, :locale
  end
end
