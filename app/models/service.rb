class Service < ApplicationRecord
  # Versioning
  has_paper_trail

  # User rights
  resourcify
  after_save :create_default_user_association
  after_save :assign_default_user_roles

  # Ancestry
  has_ancestry orphan_strategy: :adopt

  # Service rights
  rolify strict: true, role_join_table_name: 'public.services_roles'

  SERVICE_TYPES = {startup: {index: 1}, client: {index: 2}, company: {index: 3}}
  SERVICE_TYPES_ENUM = SERVICE_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum service_type: SERVICE_TYPES_ENUM

  belongs_to :user
  belongs_to :company
  belongs_to :main_commercial, class_name: User.name, foreign_key: 'main_commercial_id'
  belongs_to :main_accountant, class_name: User.name, foreign_key: 'main_accountant_id'
  belongs_to :main_developer, class_name: User.name, foreign_key: 'main_developer_id'
  has_many :proxies
  has_many :contracts, class_name: Contract.name, foreign_key: 'client_id'
  has_many :routes, through: :proxies
  has_one :contact_detail, as: :contactable, dependent: :destroy
  has_many :refresh_tokens

  has_many :user_associations, as: :associable
  has_many :users, through: :user_associations

  accepts_nested_attributes_for :contact_detail, allow_destroy: true

  before_validation :generate_identifiers

  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true, if: Proc.new{ self.public }
  validates :description_long, presence: true, if: Proc.new{ self.public }

  validates :service_type, presence: true
  before_save :public_validation

  validates :website, url: true, allow_blank: true

  validates :subdomain, presence: true, if: :confirmed_at?
  validates :subdomain, uniqueness: true, subdomain: true, length: {minimum: 2, maximum: 35}, if: Proc.new { subdomain.present? }
  validate :subdomain_changed_disallowed

  validates :client_id,     uniqueness: true,
                            format: { with: /\A[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\z/i },
                            presence: true,
                            if: Proc.new { self.is_activated? && !self.errors.has_key?(:subdomain) }
  validates :client_secret, format: { with: /\A[a-z0-9]{64}\z/i },
                            presence: true,
                            if: Proc.new { self.is_activated? && !self.errors.has_key?(:subdomain) }

  validate :company_ancestry_validation

  scope :owned, ->(user) { where(user: user) }
  scope :activated, -> { where.not(confirmed_at: nil) }
  scope :activated_startups, -> {  where('confirmed_at IS NOT NULL AND service_type = ?', SERVICE_TYPES_ENUM[:startup]) }
  scope :activated_clients, -> { where('confirmed_at IS NOT NULL AND service_type = ?', SERVICE_TYPES_ENUM[:client]) }
  scope :activated_companies, -> { where('confirmed_at IS NOT NULL AND service_type = ?', SERVICE_TYPES_ENUM[:company]) }
  scope :associated, ->(company) { where(company: company) }
  scope :companies, -> { where(service_type: SERVICE_TYPES[:company][:index]) }

  scope :published, -> { where('confirmed_at IS NOT NULL AND public = true') }

  def associated_contracts
    Contract.where('client_id = :service_id OR startup_id = :service_id', service_id: self.id)
  end

  def authorized?(user)
    user.is_superadmin? || (self.company && user.is_admin_of?(self.company)) || user.services.exists?(self)
  end

  def associated?(user)
    user.has_role?(:admin, self.company)
  end

  def generate_client_id!
    begin
      self.client_id = SecureRandom.uuid
    end while self.class.exists?(client_id: client_id)
  end

  def generate_client_secret!
    self.client_secret = SecureRandom.hex(32)
  end

  def is_activated?
    !self.confirmed_at.nil? && self.is_activable? && (!self.parent || self.parent.is_activated?)
  end

  def is_activable?
    !self.subdomain.blank?
  end

  def is_client?
    self.service_type.to_s == 'client'
  end

  def is_startup?
    self.service_type.to_s == 'startup'
  end

  def subdomain_changed_disallowed
    if self.persisted? && (subdomain_changed? && !confirmed_at_changed?) && self.is_activated?
      errors.add(:subdomain, I18n.t('activerecord.validations.service.subdomain_changed_disallowed'))
    end
  end

  def create_default_user_association
    self.user.user_associations.where(associable: self).first_or_create if self.user
    self.main_commercial.user_associations.where(associable: self).first_or_create if self.main_commercial
    self.main_accountant.user_associations.where(associable: self).first_or_create if self.main_accountant
    self.main_developer.user_associations.where(associable: self).first_or_create if self.main_developer
  end

  def assign_default_user_roles
    self.user.add_role(:admin, self) unless self.user.has_role?(:admin, self) if self.user
    self.main_commercial.add_role(:commercial, self) if self.main_commercial && !self.main_commercial.has_role?(:commercial, self)
    self.main_accountant.add_role(:commercial, self) if self.main_accountant && !self.main_accountant.has_role?(:commercial, self)
    self.main_developer.add_role(:commercial, self) if self.main_developer && !self.main_developer.has_role?(:commercial, self)
  end

  def activate
    if self.is_activable?
      self.confirmed_at = Date.new if self.confirmed_at.nil?
      self.generate_client_id! unless self.client_id.present?
      self.generate_client_secret! unless self.client_secret.present?
      self.save
    end
  end

  def reset_identifiers
    self.generate_client_id!
    self.generate_client_secret!
    self.save!
  end

  def deactivate
    self.confirmed_at = nil
    self.save
  end

  def public_validation
    if self.is_client?
      self.public = false
    end
  end

  def to_s
    name
  end

  def company_ancestry_validation
    if self.service_type.to_sym == :company
      if self.parent_id.present?
        self.errors.add(:service_type, I18n.t('activerecord.validations.service.company_must_be_root'))
        self.errors.add(:parent_id, I18n.t('activerecord.validations.service.company_must_not_depend_on_company'))
      end
    else
      if self.persisted? && self.has_children?
        self.errors.add(:service_type, I18n.t('activerecord.validations.service.root_must_be_company'))
      end
    end
  end

  def clients
    self.children.where(service_type: SERVICE_TYPES[:client][:index])
  end

  def startups
    self.children.where(service_type: SERVICE_TYPES[:startup][:index])
  end

  def is_company?
    self.service_type.to_s == 'company'
  end

  def company
    @company ||= self.parent
  end

  def generate_identifiers
    self.generate_client_id! unless self.client_id.present?
    self.generate_client_secret! unless self.client_secret.present?
  end

  def can?(user, controller_name, action_name)
    roles = Role::CONTROLLER_AUTHORIZATIONS[controller_name.to_sym][action_name.to_sym] || []
    roles.each do |role|
      return true if user.send("is_#{role}_of?", self)
    end
    false
  end
end
