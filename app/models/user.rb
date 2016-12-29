class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # User rights
  rolify role_join_table_name: 'public.users_roles'

  has_many :services
  has_many :proxies
  has_many :routes
end
