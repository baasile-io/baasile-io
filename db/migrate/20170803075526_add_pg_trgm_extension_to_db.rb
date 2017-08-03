class AddPgTrgmExtensionToDb < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        execute "create extension pg_trgm;"
      }
    end
  end
end
