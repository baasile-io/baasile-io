class AddRevokedValueToMeasureTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :measure_tokens, :is_active, :boolean, default: true
  end
end
