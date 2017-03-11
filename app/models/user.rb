class User < ApplicationRecord
  # Versioning
  has_paper_trail

  has_ancestry orphan_strategy: :adopt

  # Include default devise modules. Others available are:
  #  :omniauthable :password_archivable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :trackable, :secure_validatable, :confirmable, :lockable,
         :password_expirable, :session_limitable, :expirable

  GENDERS = {male: 1, female: 2}
  enum gender: GENDERS

  # User rights
  rolify strict: true, role_join_table_name: 'public.users_roles'

  has_many :companies
  #has_many :services
  has_many :proxies
  has_many :routes
  has_many :query_parameters

  has_many :user_associations
  has_many :services, through: :user_associations, source: :associable, source_type: Service.name

  validates :email, presence: true, uniqueness: true
  validates :gender, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, phone: true, if: Proc.new { self.phone.present? }

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : subtree_of(user) }

  def is_superadmin?
    self.has_role?(:superadmin)
  end

  def is_admin?
    self.has_role?(:superadmin) || self.has_role?(:admin)
  end

  def is_commercial?
    self.has_role?(:superadmin) || self.has_role?(:commercial)
  end

  def is_admin_of?(obj)
    self.has_role?(:superadmin) || self.has_role?(:admin, obj)
  end

  def full_name
    self.first_name.present? && self.last_name.present? ? "#{self.first_name} #{self.last_name}" : self.email
  end

  def to_s
    full_name
  end

end
