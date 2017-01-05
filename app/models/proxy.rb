class Proxy < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role

  belongs_to :service
  belongs_to :user

  belongs_to :proxy_parameter
  has_many :routes

  accepts_nested_attributes_for :proxy_parameter

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self)
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end
end