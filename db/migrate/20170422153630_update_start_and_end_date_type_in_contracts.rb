class UpdateStartAndEndDateTypeInContracts < ActiveRecord::Migration[5.0]
  def change
    change_column :contracts, :start_date, :date
    change_column :contracts, :end_date, :date
  end
end
