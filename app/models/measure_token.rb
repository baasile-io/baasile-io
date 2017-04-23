class MeasureToken < ApplicationRecord
  TOKEN_LABEL = "MeasureTokenID"

  belongs_to  :contract
  before_save :is_unique?

  scope :by_token, ->(token) { where(value: token) }
  scope :unique_token, ->(token, contract, status) { where(value: token, contract: contract, contract_status: status).first }
  scope :by_contract_status, ->(contract, status) { where(contract: contract, contract_status: status) }

  def generate_token
    begin
      self.value = SecureRandom.uuid
    end while self.class.exists?(value: value)
    yield
  end

  def already_exist?
    return true if MeasureToken.where(value: self.value, contract: self.contract, contract_status: self.contract_status).nil?
    return false
  end

end
