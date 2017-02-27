class RefreshToken < ApplicationRecord
  belongs_to :service

  before_validation :expires_token

  around_create :generate_token

  def expires_token
    self.expires_at = 1.month.from_now
  end

  def generate_token
    begin
      self.value = SecureRandom.uuid
    end while self.class.exists?(value: value)
    yield
  end
end