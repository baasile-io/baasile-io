class RenameAttrOnContracts < ActiveRecord::Migration[5.0]
  def change
    rename_column :contracts, :general_condition_validated_client_id, :general_condition_validated_client_user_id
  end
end
