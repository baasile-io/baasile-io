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

  has_many :companies
  has_many :services
  has_many :proxies
  has_many :routes
  has_many :query_parameters
  has_many :prices
  has_many :price_parameters

  has_many :user_associations
  has_many :services, through: :user_associations, source: :associable, source_type: Service.name
  has_many :companies, through: :user_associations, source: :associable, source_type: Company.name

  validates :phone, phone: true
  validates :email, presence: true, uniqueness: true
  validates :gender, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def is_superadmin?
    self.has_role?(:superadmin)
  end

  def is_admin?
    self.has_role?(:superadmin) || self.has_role?(:admin)
  end

  def is_commercial?
    self.has_role?(:superadmin) || self.has_role?(:commercial, :any)
  end

  def is_commercial_to_create?
    self.has_role?(:superadmin) || self.has_role?(:commercial)
  end

  def is_admin_of?(obj)
    self.has_role?(:superadmin) || self.has_role?(:admin, obj)
  end

  def full_name
    self.first_name.present? && self.last_name.present? ? "#{I18n.t("types.genders.#{self.gender}")} #{self.first_name} #{self.last_name}" : self.email
  end

  def to_s
    full_name
  end

end
