class AddIsPlatformContributionToBillLines < ActiveRecord::Migration[5.0]
  def change
    add_column :bill_lines, :is_platform_contribution, :boolean, default: false
  end
end
