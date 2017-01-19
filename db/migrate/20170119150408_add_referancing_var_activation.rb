class AddReferancingVarActivation < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :is_referanced, :boolean, default: false
  end
end
