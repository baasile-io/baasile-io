class AddCompqnyIdToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :company_id, :integer, null: true
  end
end
