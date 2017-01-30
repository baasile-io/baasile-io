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


  def is_superadmin
    return self.has_role?(:superadmin)
  end

end
