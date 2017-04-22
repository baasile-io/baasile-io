class RenameCgVersionToGcVersion < ActiveRecord::Migration[5.0]
  def change
    rename_column :general_conditions, :cg_version, :gc_version
  end
end
