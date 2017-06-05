class Identifier < ApplicationRecord
  # Versioning
  has_paper_trail

  attr_accessor :client_secret

  belongs_to :identifiable, polymorphic: true, touch: true

  validates :client_id, presence: true, uniqueness: {scope: [:identifiable_type, :identifiable_id]}
  validate :encrypted_secret_validation

  before_validation :encrypt_secret

  def decrypt_secret
    self.client_secret = DataEncryption.decrypt_secret(self.encrypted_secret) unless self.encrypted_secret.nil?
  end

  private

  def encrypt_secret
    self.encrypted_secret = DataEncryption.encrypt_secret(self.client_secret) if self.client_secret.present?
  end

  def encrypted_secret_validation
    if self.encrypted_secret.nil?
      self.errors.add :client_secret, I18n.t('errors.messages.blank')
    end
  end
end
