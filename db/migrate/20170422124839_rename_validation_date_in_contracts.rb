class RenameValidationDateInContracts < ActiveRecord::Migration[5.0]
  def change
    rename_column :contracts, :validation_date, :general_condition_validated_client_datetime
    change_column :contracts, :general_condition_validated_client_datetime, :datetime
  end
end
