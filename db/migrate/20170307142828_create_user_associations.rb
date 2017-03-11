class CreateUserAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_associations do |t|
      t.references :associable, polymorphic: true
      t.belongs_to :user
      t.timestamps
    end

    add_index :user_associations, [:user_id, :associable_type, :associable_id], name: "id_userassociations_user_associable"

    add_column :users, :ancestry, :string

    reversible do |direction|
      direction.up {
        [Company, Service].each do |collection|
          collection.all.each do |company|
            User.with_role(:admin, company).each do |u|
              UserAssociation.first_or_create(associable: company, user: u)
            end
            User.with_role(:commercial, company).each do |u|
              UserAssociation.first_or_create(associable: company, user: u)
            end
          end
        end
      }
    end
  end
end
