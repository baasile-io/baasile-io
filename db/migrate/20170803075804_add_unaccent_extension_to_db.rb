class AddUnaccentExtensionToDb < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        execute "create extension unaccent;"
      }
    end
  end
end
