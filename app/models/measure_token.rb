class MeasureToken < ApplicationRecord
  belongs_to  :contract
  before_save :generate_token_value, if: Proc.new { self.value.blank? }

  validates :contract_id, presence: true
  validates :value, uniqueness: {scope: [:contract_id, :contract_status]}

  scope :by_contract_status, ->(contract) { where(contract: contract, contract_status: contract.status) }

  def generate_token_value
    begin
      self.value = SecureRandom.uuid
    end while self.class.exists?(value: self.value)
  end

  def already_exist?
    return true if MeasureToken.where(value: self.value, contract: self.contract, contract_status: self.contract_status).nil?
    return false
  end

end
