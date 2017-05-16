class MeasureToken < ApplicationRecord
  belongs_to  :contract

  has_one :startup, through: :contract, foreign_key: 'startup_id'
  has_one :client, through: :contract, foreign_key: 'client_id'

  before_save :generate_token_value, if: Proc.new { self.value.blank? }

  validates :contract_id, presence: true
  validates :value, uniqueness: true

  scope :by_contract_status, ->(contract) { where(contract: contract, contract_status: contract.status) }

  def generate_token_value
    begin
      self.value = SecureRandom.uuid
    end while self.class.exists?(value: self.value)
  end

  def revoked
    !is_active
  end
end
