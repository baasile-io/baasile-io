class Route < ApplicationRecord
  # Versioning
  has_paper_trail

  resourcify
  after_create :assign_default_user_role

  PROTOCOLS = {https: 1, http: 2}
  PROTOCOLS_TEST = {https: 1, http: 2}
  enum protocol: PROTOCOLS, _prefix: true
  enum protocol_test: PROTOCOLS_TEST, _prefix: true

  ALLOWED_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']

  belongs_to :proxy
  has_one :service, through: :proxy
  belongs_to :user
  has_many :query_parameters
  validates :hostname, hostname: true, if: Proc.new { hostname.present? }
  validates :hostname_test, hostname: true, if: Proc.new { hostname_test.present? }
  validates :subdomain, uniqueness: {scope: :proxy_id}, presence: true, subdomain: true, length: {minimum: 2, maximum: 35}

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }

  validates :name, uniqueness: {scope: :proxy_id}, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true
  validates :url, format: {with: /\A\//}, presence: true
  validate :validate_methods

  def validate_methods
    if !allowed_methods.is_a?(Array)
      errors.add(:allowed_methods, :invalid)
      return
    end

    # rails adds an empty value to allow to uncheck all values
    # we need to delete this value before validating the array
    allowed_methods.delete ''

    if !allowed_methods.any? || allowed_methods.detect {|m| !ALLOWED_METHODS.include?(m)}
      errors.add(:allowed_methods, :invalid)
    end
  end

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.proxy)
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end

  def uri
    "#{protocol || proxy.proxy_parameter.protocol}://#{hostname.present? ? hostname : proxy.proxy_parameter.hostname}:#{port.present? ? port : proxy.proxy_parameter.port}#{url}"
  end

  def uri_test
    "#{protocol_test || proxy.proxy_parameter_test.protocol}://#{hostname_test.present? ? hostname_test : proxy.proxy_parameter_test.hostname}:#{port_test.present? ? port_test : proxy.proxy_parameter_test.port}#{url}"
  end

  def to_s
    name
  end
end
