class Route < ApplicationRecord

  PROTOCOLS = {https: 1, http: 2}
  enum protocol: PROTOCOLS

  belongs_to :functionality
  belongs_to :user

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.functionality)
  end

end
