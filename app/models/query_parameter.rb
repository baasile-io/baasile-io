class QueryParameter < ApplicationRecord
  belongs_to :route

  ATTRIBUTE_MODE = ['NEEDED', 'OPTIONAL', 'FORBIDEN']

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.route)
  end

end
