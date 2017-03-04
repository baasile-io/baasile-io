class CreateUserAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_associations do |t|
      t.references :associable, polymorphic: true
      t.belongs_to :user
      t.timestamps
    end

    add_index :user_associations, [:user_id, :associable_type, :associable_id], name: "id_userassociations_user_associable"

    reversible do |direction|
      direction.up {
        [Company, Service].each do |collection|
          collection.all.each do |obj|
            Role::USER_ROLES.each do |role|
              User.with_role(role, obj).each do |u|
                UserAssociation.where(associable: obj, user: u).first_or_create
              end
            end
            if obj.user
              UserAssociation.where(associable: obj, user: obj.user).first_or_create
              obj.user.add_role(:admin, obj)
            end
          end
        end
      }
    end
  end
end
