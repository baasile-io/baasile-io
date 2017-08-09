class CreateTesterInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :tester_infos do |t|
      t.string :proxy_id
      t.string :service_id
      t.integer :user_id
      t.string :auth_url
      t.string :req_url
      t.integer :req_type

      t.timestamps
    end
  end
end
