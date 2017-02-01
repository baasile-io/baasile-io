class CreateContactDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_details do |t|
      t.references :contactable, polymorphic: true, index: true
      t.string :name, limit: 255
      t.string :siret, limit: 255
      t.string :address_line1, limit: 255
      t.string :address_line2, limit: 255
      t.string :address_line3, limit: 255
      t.string :zip, limit: 255
      t.string :city, limit: 255
      t.string :country, limit: 255
      t.string :phone, limit: 255

      t.timestamps
    end
    add_index :contact_details, [:name, :contactable_type, :contactable_id], name: "id_contdetails_name_type_and_id"
  end
end
