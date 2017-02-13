class CreateRefreshTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :refresh_tokens do |t|
      t.string :value
      t.belongs_to :service
      t.datetime :expires_at
      t.string :scope

      t.timestamps
    end
  end
end
