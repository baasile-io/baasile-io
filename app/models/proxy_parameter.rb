class ProxyParameter < ApplicationRecord
  AUTHENTICATION_MODES = {null: {index: 0, authentication_required: false},
                          oauth2: {index: 1, authentication_required: true}}
  AUTHENTICATION_MODES_ENUM = AUTHENTICATION_MODES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum authentication_mode: AUTHENTICATION_MODES_ENUM

  PROTOCOLS = {https: 1, http: 2}
  enum protocol: PROTOCOLS

  has_many :functionalities

  validates :authentication_mode, presence: true

  validates :protocol, presence: true
  validates :hostname, presence: true
  validates :port, presence: true, numericality: {greater_than: 0}
  validates :authentication_url, presence: true, if: :authentication_required?

  def authentication_required?
    return false if self.authentication_mode.nil?
    AUTHENTICATION_MODES[self.authentication_mode.to_sym][:authentication_required]
  end
end
