class AddExpectedResponseFormatToTesterRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :tester_requests, :expected_response_format, :string
  end
end
