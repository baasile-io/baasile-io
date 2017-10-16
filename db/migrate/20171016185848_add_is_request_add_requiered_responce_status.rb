class AddIsRequestAddRequieredResponceStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :tester_parameters, :is_request, :boolean, default: true
    add_column :tester_requests, :required_responce_status, :integer, null: true
  end
end
