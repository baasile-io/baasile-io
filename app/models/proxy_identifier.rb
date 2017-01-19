class ProxyIdentifier < ApplicationRecord

  attr_accessor :client_secret

  belongs_to :proxy
  belongs_to :user

  validates_uniqueness_of :client_id, scope: [:encrypted_secret]

  before_save :encrypt_secret

  private
  def encrypt_secret
    self.encrypted_secret = DataEncryption.encrypt_secret(self.client_secret)
    crypt.decrypt_and_verify(encrypted_data)
  end

end
