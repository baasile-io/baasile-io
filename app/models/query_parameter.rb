class QueryParameter < ApplicationRecord
  MODES = {
    optional: 1,
    mandatory: 2,
    forbidden: 3
  }
  enum mode: MODES

  QUERY_PARAMETER_TYPES = {
    get: 1,
    header: 3
  }
  enum query_parameter_type: QUERY_PARAMETER_TYPES

  # Versioning
  has_paper_trail

  belongs_to :route
  belongs_to :user

  validates :name, presence: true, uniqueness: {scope: [:query_parameter_type, :route_id]}
  validates :name, format: {without: /\[\]/ }
  validates :name, format: {without: /\A\[/ }
  validates :mode, presence: true
  validates :query_parameter_type, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }
  scope :by_types, ->(types) { where(query_parameter_type: types) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.route)
  end

end
