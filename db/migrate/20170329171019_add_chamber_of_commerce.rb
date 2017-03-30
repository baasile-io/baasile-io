class AddChamberOfCommerce < ActiveRecord::Migration[5.0]
  def change
    add_column :contact_details, :chamber_of_commerce, :string, limit: 255, default: nil
  end
end
