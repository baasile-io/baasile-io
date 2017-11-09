class AddExpirationDateToTesterRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :tester_requests, :expiration_date, :datetime
  end
end
