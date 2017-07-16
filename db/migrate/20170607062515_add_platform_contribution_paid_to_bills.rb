class AddPlatformContributionPaidToBills < ActiveRecord::Migration[5.0]
  def change
    add_column :bills, :platform_contribution_paid, :boolean, default: false
    add_column :bills, :startup_paid, :boolean, default: false

    add_column :bills, :platform_contribution_cost, :decimal, default: 0.0
    add_column :bills, :platform_contribution_vat, :decimal, default: 0.0
    add_column :bills, :platform_contribution_cost_including_vat, :decimal, default: 0.0
    add_column :bills, :startup_cost, :decimal, default: 0.0
    add_column :bills, :startup_vat, :decimal, default: 0.0
    add_column :bills, :startup_cost_including_vat, :decimal, default: 0.0
  end
end
