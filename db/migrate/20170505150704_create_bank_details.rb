class CreateBankDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_details do |t|
      t.string      :name
      t.string      :iban
      t.string      :bic
      t.string      :account_owner
      t.string      :bank_name

      t.belongs_to  :user
      t.belongs_to  :service
      t.belongs_to  :contract

      t.timestamps
    end

    add_index :bank_details, [:name, :service_id, :contract_id], unique: true, name: 'index_on_name_service_contract'
  end
end
