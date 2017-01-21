class ProxyIdentifier < ApplicationRecord

  attr_accessor :client_secret

  belongs_to :proxy
  belongs_to :user

  validates :client_id, presence: true
  validates_uniqueness_of :client_id, scope: [:proxy_id]
  validate :expires_at_attribute

  before_save :encrypt_secret

  private
  def encrypt_secret
    if self.client_secret.present?
      self.encrypted_secret = DataEncryption.encrypt_secret(self.client_secret)
      self.client_secret = nil
    end
  end

  def expires_at_attribute
    unless self.expires_at.nil?
      if self.expires_at < DateTime.now
        self.errors.add :expires_at, I18n.t('errors.messages.not_in_the_future')
      end
    end
  end

end
