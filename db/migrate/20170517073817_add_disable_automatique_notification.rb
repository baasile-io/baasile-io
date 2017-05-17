class AddDisableAutomatiqueNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_active_notification_measurement_errors,  :boolean, default: true
    add_column :users, :is_active_notification_contract_status,     :boolean, default: true
    add_column :users, :is_active_notification_ticket,              :boolean, default: true
    add_column :users, :is_active_notification_service_validation,  :boolean, default: true
  end
end
