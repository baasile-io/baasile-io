class ChangeBooleansToDatesOnBills < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {

        add_column :bills, :platform_contribution_paid_date, :datetime
        add_column :bills, :startup_paid_date,               :datetime
        add_column :bills, :paid_date,                       :datetime

        execute "UPDATE bills SET platform_contribution_paid_date = NOW() WHERE platform_contribution_paid"
        execute "UPDATE bills SET startup_paid_date = NOW() WHERE startup_paid"
        execute "UPDATE bills SET paid_date = NOW() WHERE paid"

        remove_column :bills, :platform_contribution_paid, :boolean
        remove_column :bills, :startup_paid,               :boolean
        remove_column :bills, :paid,                       :boolean

        rename_column :bills, :platform_contribution_paid_date, :platform_contribution_paid
        rename_column :bills, :startup_paid_date,               :startup_paid
        rename_column :bills, :paid_date,                       :paid

      }

      direction.down {

        add_column :bills, :platform_contribution_paid_boolean, :boolean, default: false
        add_column :bills, :startup_paid_boolean,               :boolean, default: false
        add_column :bills, :paid_boolean,                       :boolean, default: false

        execute "UPDATE bills SET platform_contribution_paid_boolean = true WHERE platform_contribution_paid IS NOT NULL"
        execute "UPDATE bills SET startup_paid_boolean = true WHERE startup_paid IS NOT NULL"
        execute "UPDATE bills SET paid_boolean = true WHERE paid IS NOT NULL"

        remove_column :bills, :platform_contribution_paid, :datetime
        remove_column :bills, :startup_paid,               :datetime
        remove_column :bills, :paid,                       :datetime

        rename_column :bills, :platform_contribution_paid_boolean, :platform_contribution_paid
        rename_column :bills, :startup_paid_boolean,               :startup_paid
        rename_column :bills, :paid_boolean,                       :paid

      }
    end

  end
end
