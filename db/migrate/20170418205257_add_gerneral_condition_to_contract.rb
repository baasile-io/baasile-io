class AddGerneralConditionToContract < ActiveRecord::Migration[5.0]
  def change
    add_column :contracts, :general_condition_id, :integer, default: nil
    add_column :contracts, :general_condition_validated_client_id, :integer, default: nil
  end
end
