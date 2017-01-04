class Route < ApplicationRecord
  PROTOCOLS = {https: 1, http: 2}
  enum protocol: PROTOCOLS

  ALLOWED_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']

  belongs_to :proxy
  has_one :service, through: :proxy
  belongs_to :user
  has_many :query_parameters

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true
  validate :validate_methods

  def validate_methods
    if !allowed_methods.is_a?(Array)
      errors.add(:allowed_methods, :invalid)
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

  def uri
    "#{protocol || proxy.proxy_parameter.protocol}://#{hostname}:#{port}#{url}"
  end
end
