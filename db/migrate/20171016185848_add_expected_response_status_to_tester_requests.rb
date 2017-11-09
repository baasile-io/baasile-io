class AddExpectedResponseStatusToTesterRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :tester_requests, :expected_response_status, :integer, null: true
  end
end
