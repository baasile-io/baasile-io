class Ticket < ApplicationRecord
  # Versioning
  has_paper_trail

  TICKET_TYPES = {activation_demand: 1, bug: 2, user_right_demand: 3, info_demand: 4}
  TICKET_STATUSES = {opened: 1, in_progress: 2, closed: 3}
  enum ticket_type: TICKET_TYPES
  enum ticket_status: TICKET_STATUSES

  belongs_to  :user
  belongs_to  :service

  has_many :comments, as: :commentable

  validates :subject, presence: true, length: {minimum: 2, maximum: 255}
  validates :user, presence: true
  validates :ticket_type, presence: true
  validates :ticket_status, presence: true

  scope :owned, ->(user) { where(user: user) }
  scope :by_type, ->(ticket_type) { where(ticket_type: ticket_type) }
  scope :owned_by_type, ->(user, ticket_type) { where(user: user, ticket_type: ticket_type) }
  scope :not_closed, -> { where.not(ticket_status: :closed) }
  scope :closed, -> { where(ticket_status: :closed) }

end
