class AddDictionariesToCategories < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        Category.destroy_all
      }
    end

    remove_column :categories, :name, :string
    remove_column :categories, :description, :string
  end
end
