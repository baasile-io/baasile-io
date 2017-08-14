class Proxy < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role

  include Trixable
  has_trix_attributes_restricted :description_long

  # Versioning
  has_paper_trail

  belongs_to  :service, touch: true
  belongs_to  :user
  belongs_to  :category
  belongs_to  :proxy_parameter, dependent: :destroy
  belongs_to  :proxy_parameter_test, class_name: ProxyParameter.name, foreign_key: 'proxy_parameter_test_id', dependent: :destroy

  has_many    :routes, dependent: :destroy
  has_many    :prices, dependent: :destroy
  has_one     :identifier, as: :identifiable, through: :proxy_parameter, dependent: :destroy
  has_many    :query_parameters, through: :routes, dependent: :destroy
  has_many    :contracts, dependent: :restrict_with_error
  has_many    :error_measurements, through: :contracts, dependent: :destroy

  accepts_nested_attributes_for :proxy_parameter
  accepts_nested_attributes_for :proxy_parameter_test

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :name, uniqueness: {scope: :service_id, case_sensitive: false}
  validates :description, presence: true, length: {minimum: 2, maximum: 155}
  validates :subdomain, uniqueness: {scope: :service_id, case_sensitive: false}, presence: true, subdomain: true, length: {minimum: 2, maximum: 35}
  validates :proxy_parameter, presence: true
  validates :proxy_parameter_test, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }
  scope :associated_services, ->(service) { where(service: service) }
  scope :published, -> { where(public: true) }

  scope :from_activated_and_published_startups, -> {
    joins(:service).merge(Service.activated_startups).merge(Service.published)
  }

  scope :without_category, -> { where('category_id IS NULL') }
  scope :by_category, -> (category)  { where(category: category) }

  scope :look_for, -> (q) {
    includes(:service).
      where("(proxies.name <-> :q_orig) < 0.4
           OR UPPER(unaccent(proxies.name))    SIMILAR TO UPPER(unaccent(:q_repeat))
           OR unaccent(proxies.name)           ILIKE unaccent(:q)
           OR unaccent(proxies.description)    ILIKE unaccent(:q)
           OR unaccent(services.name)            ILIKE unaccent(:q)
           OR unaccent(services.description)     ILIKE unaccent(:q)
          ", q_orig: q, q: "%#{q.gsub(/\s/, '%')}%", q_repeat: "%#{q.gsub(/\W+/, ' ').gsub(/(\S)/, '\1+').gsub(/\s/, '%')}%").
      references(:services)
  }

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

  def authorization_uri_test
    "#{proxy_parameter_test.protocol}://#{proxy_parameter_test.hostname}:#{proxy_parameter_test.port}#{proxy_parameter_test.authorization_url}"
  end

  def cache_token
    "proxy_cache_token_#{proxy_parameter.authorization_mode}_#{id}_#{proxy_parameter.updated_at.strftime('%Y%M%d%H%I%S')}"
  end

  def cache_token_test
    "proxy_cache_token_test_#{proxy_parameter_test.authorization_mode}_#{id}_#{proxy_parameter_test.updated_at.strftime('%Y%M%d%H%I%S')}"
  end

  def local_url(version = 'v1')
    "#{self.service.local_url(version)}/proxies/#{self.subdomain}"
  end

  def has_get_context?
    self.routes.where(name: 'getContext').count == 1
  end

  def to_s
    name
  end
end
