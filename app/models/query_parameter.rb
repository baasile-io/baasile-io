class QueryParameter < ApplicationRecord
  MODES = {optional: 1, mandatory: 2, forbidden: 3}
  enum mode: MODES

  QUERY_PARAMETER_TYPES = {get: 1, body: 2, header: 3}
  enum query_parameter_type: QUERY_PARAMETER_TYPES

  # Versioning
  has_paper_trail

  belongs_to :route
  belongs_to :user

  has_many  :Measurements

  validates :name, presence: true, uniqueness: {scope: [:query_parameter_type, :route_id]}
  validates :mode, presence: true
  validates :query_parameter_type, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self.route)
  end

end
