class Route < ApplicationRecord
  PROTOCOLS = {https: 1, http: 2}
  enum protocol: PROTOCOLS

  belongs_to :proxy
  has_one :service, through: :proxy
  belongs_to :user

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.proxy)
  end
end
