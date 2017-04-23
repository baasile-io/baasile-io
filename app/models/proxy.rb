class Proxy < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role

  # Versioning
  has_paper_trail

  belongs_to :service
  belongs_to :user
  belongs_to :category

  belongs_to :proxy_parameter
  belongs_to :proxy_parameter_test, class_name: ProxyParameter.name, foreign_key: 'proxy_parameter_test_id'
  has_many :routes
  has_many :prices
  has_one :identifier, as: :identifiable, through: :proxy_parameter
  has_many :query_parameters, through: :routes

  accepts_nested_attributes_for :proxy_parameter
  accepts_nested_attributes_for :proxy_parameter_test

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :name, uniqueness: {scope: :service_id}
  validates :description, presence: true
  validates :subdomain, uniqueness: {scope: :service_id}, presence: true, subdomain: true, length: {minimum: 2, maximum: 35}

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }
  scope :associated_service, ->(service) { where(service: service) }
  scope :published, -> { where(public: true) }

  def service_proxy_name
    return self.service.name + " - " + self.name
  end

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self)
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end

  def authorization_uri
    "#{proxy_parameter.protocol}://#{proxy_parameter.hostname}:#{proxy_parameter.port}#{proxy_parameter.authorization_url}"
  end

  def cache_token
    "proxy_cache_token_#{proxy_parameter.authorization_mode}_#{id}_#{proxy_parameter.updated_at}"
  end

  def has_get_context?
    self.routes.where(name: 'getContext').count == 1
  end

  def to_s
    name
  end
end
