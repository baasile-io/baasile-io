class AddLocaleParametersToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :language, :string, default: 'en'
    change_column :users, :is_active, :boolean, default: true

    reversible do |direction|
      direction.up {
        User.update_all(language: 'fr')
      }
    end
  end
end