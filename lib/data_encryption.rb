class DataEncryption
  @@secret_crypt = ActiveSupport::MessageEncryptor.new(ActiveSupport::KeyGenerator.new('encrypted_secret').generate_key(Rails.application.secrets.secret_key_base))

  def self.secret_crypt
    @@secret_crypt
  end

  def encrypt_secret(value)
    secret_crypt.encrypt_and_sign(value)
  end

  def decrypt_secret(value)
    secret_crypt.decrypt_and_verify(value)
  end
end
