class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :confirmable, :lockable

  GENDERS = {male: 1, female: 2}
  enum gender: GENDERS

  # User rights
  rolify role_join_table_name: 'public.users_roles'

  has_many :companies
  has_many :services
  has_many :proxies
  has_many :routes
  has_many :query_parameters

  after_find do |user|
    puts "user find"
  end

  def is_superadmin?
    self.has_role?(:superadmin)
  end

  def is_admin?
    companies = Company.all.reject { |obj| !self.has_role?(:admin, obj) }
    return companies.count > 0
  end

  def is_admin_of?(obj)
    self.has_role?(:admin, obj)
  end

  def full_name
    self.first_name.present? && self.last_name.present? ? "#{self.first_name} #{self.last_name}" : self.email
  end

end
