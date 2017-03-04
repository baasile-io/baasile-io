class QueryParameter < ApplicationRecord
  MODES = {optional: 1, mandatory: 2, forbidden: 3}
  enum mode: MODES

  # Versioning
  has_paper_trail

  belongs_to :route
  belongs_to :user

  validates :name,  presence: true, uniqueness: {scope: :route_id}


  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.route)
  end

end
