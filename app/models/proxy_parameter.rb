class ProxyParameter < ApplicationRecord
  AUTHORIZATION_MODES = {null: {index: 0, authorization_required: false},
                          oauth2: {index: 1, authorization_required: true}}
  AUTHORIZATION_MODES_ENUM = AUTHORIZATION_MODES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum authorization_mode: AUTHORIZATION_MODES_ENUM

  PROTOCOLS = {https: {index: 1, default_port: 443}, http: {index: 2, default_port: 80}}
  PROTOCOLS_ENUM = PROTOCOLS.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum protocol: PROTOCOLS_ENUM

  has_one :proxy, dependent: :destroy
  has_one :identifier, as: :identifiable, dependent: :destroy

  accepts_nested_attributes_for :identifier

  validates :follow_url, inclusion: { in: [true, false] }
  validates :follow_redirection, presence: true, numericality: {greater_than_or_equal: 0, less_than: 21}
  validates :authorization_mode, presence: true
  validates :protocol, presence: true
  validates :hostname, presence: true, hostname: true
  validates :port, presence: true, numericality: {greater_than: 0}
  validates :authorization_url, format: {with: /\A\//}, presence: true, if: :authorization_required?
  validates :identifier, presence: true, if: :authorization_required?

  def authorization_required?
    return false if self.authorization_mode.nil?
    AUTHORIZATION_MODES[self.authorization_mode.to_sym][:authorization_required] rescue false
  end

  attr_accessor :scopes

  def scopes
    self.scope.split(' ')
  end

  def scopes=(val)
    if val.is_a?(Array)
      self.scope = val.join(' ')
    else
      self.scope = val.to_s
    end
  end
end
