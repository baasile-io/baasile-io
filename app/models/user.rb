class User < ApplicationRecord
  # Versioning
  has_paper_trail

  # Include default devise modules. Others available are:
  #  :omniauthable :password_archivable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :trackable, :secure_validatable, :confirmable, :lockable,
         :password_expirable, :session_limitable, :expirable

  GENDERS = {male: 1, female: 2}
  enum gender: GENDERS

  # User rights
  rolify strict: true, role_join_table_name: 'public.users_roles'

  # Ancestry
  has_ancestry orphan_strategy: :adopt

  has_many :bank_details
  has_many :tickets, dependent: :destroy
  has_many :categories, dependent: :nullify
  has_many :companies, dependent: :nullify
  has_many :services, dependent: :nullify
  has_many :proxies, dependent: :nullify
  has_many :routes, dependent: :nullify
  has_many :query_parameters, dependent: :nullify
  has_many :prices, dependent: :nullify
  has_many :price_parameters, dependent: :nullify

  has_many :user_associations, dependent: :destroy
  has_many :services, through: :user_associations, source: :associable, source_type: Service.name, dependent: :nullify
  has_many :companies, through: :user_associations, source: :associable, source_type: Company.name, dependent: :nullify

  has_many :services_as_main_commercial, class_name: Service.name, primary_key: 'main_commercial_id', dependent: :nullify
  has_many :services_as_main_accountant, class_name: Service.name, primary_key: 'main_accountant_id', dependent: :nullify
  has_many :services_as_main_developer, class_name: Service.name, primary_key: 'main_developer_id', dependent: :nullify

  validates :phone, phone: true, if: Proc.new {self.phone.present?}
  validates :email, presence: true, uniqueness: true
  validates :gender, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :language, inclusion: {in: I18n.available_locales.map(&:to_s)}

  def is_activated?
    !self.confirmed_at.nil? && self.is_active
  end

  def is_superadmin?
    self.has_role?(:superadmin)
  end

  def is_admin?
    self.is_superadmin? || self.has_role?(:admin)
  end

  def is_commercial?
    self.is_superadmin? || self.has_role?(:admin, :any) || self.has_role?(:commercial, :any)
  end

  def is_user_of?(service)
    return true if service.users.exists?(self) || self.is_superadmin?
    false
  end

  def is_developer_of?(service)
    return true if self.has_role?(:superadmin)
    return true if service.users.exists?(self) && (self.has_role?(:developer, service) || service.main_developer == self)
    return true if service.company && service.company.users.exists?(self) && (self.has_role?(:developer, service.company) || service.company.main_developer == self)
    self.is_admin_of?(service)
  end

  def is_accountant_of?(service)
    return true if self.has_role?(:superadmin)
    return true if service.users.exists?(self) && (self.has_role?(:accountant, service) || service.main_accountant == self)
    return true if service.company && service.company.users.exists?(self) && (self.has_role?(:accountant, service.company) || service.company.main_accountant == self)
    self.is_admin_of?(service)
  end

  def is_commercial_of?(service)
    return true if self.has_role?(:superadmin)
    return true if service.users.exists?(self) && (self.has_role?(:commercial, service) || service.main_commercial == self)
    return true if service.company && service.company.users.exists?(self) && (self.has_role?(:commercial, service.company) || service.company.main_commercial == self)
    self.is_admin_of?(service)
  end

  def is_admin_of?(service)
    return true if self.has_role?(:superadmin)
    return true if service.users.exists?(self) && (self.has_role?(:admin, service) || service.user == self)
    return true if service.company && service.company.users.exists?(self) && (self.has_role?(:admin, service.company) || service.company.user == self)
    false
  end

  def full_name
    self.first_name.present? && self.last_name.present? ? "#{I18n.t("types.genders.#{self.gender}")} #{self.first_name} #{self.last_name}" : self.email
  end

  def to_s
    full_name
  end

end
