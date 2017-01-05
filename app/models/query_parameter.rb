class QueryParameter < ApplicationRecord

  MODES = {mandatory: 1, optional: 2, forbidden: 3}
  enum mode: MODES

  belongs_to :route

  validates :name, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.route)
  end

end
