class AddComparisonOperatorAndExpectedTypeToTesterRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :tester_parameters, :expected_type, :string, default: 'string'
    add_column :tester_parameters, :comparison_operator, :string, default: '='
  end
end
