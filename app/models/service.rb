class Service < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role

  belongs_to :user
  belongs_to :company
  has_many :proxies
  has_many :routes, through: :proxies

  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  validates :subdomain, uniqueness: true, if: Proc.new { !subdomain.nil? }
  validates :subdomain, presence: true, format: {with: /[a-z]*/}, length: {minimum: 2, maximum: 15}, if: :is_activated?
  validate :subdomain_changed_disallowed

  validates :client_id,     uniqueness: true,
                            format: { with: /\A[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\z/i },
                            presence: true,
                            if: :confirmed_at?
  validates :client_secret, format: { with: /\A[a-z0-9]{64}\z/i },
                            presence: true,
                            if: :confirmed_at?

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }
  scope :owned, ->(user) { where(user_id: user.id) }
  scope :activated, -> { where.not(confirmed_at: nil) }

  scope :published, -> { where.not(confirmed_at: nil) and where(public: true) }

  # Service rights
  rolify role_join_table_name: 'public.services_roles'

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self)
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
    !self.confirmed_at.nil?
  end

  def is_activable?
    !self.subdomain.blank?
  end

  def subdomain_changed_disallowed
    if self.persisted? && subdomain_changed? && self.is_activated?
      errors.add(:subdomain, I18n.t('activerecord.validations.service.subdomain_changed_disallowed'))
    end
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end

  def activate
    if self.is_activable?
      self.confirmed_at = Date.new if self.confirmed_at.nil?
      self.generate_client_id!
      self.generate_client_secret!
      self.save
    end
  end

  def deactivate
    self.confirmed_at = nil
    self.save
  end
end
