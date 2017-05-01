class Ticket < ApplicationRecord
  # Versioning
  has_paper_trail

  TICKET_STATUSES = {
    opened: {
      index: 1,
      notifications: ['user']
    },
    in_progress: {
      index: 2,
      notifications: ['user']
    },
    closed: {
      index: 3,
      notifications: ['user']
    },
  }

  TICKET_STATUSES_ENUM = TICKET_STATUSES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum ticket_status: TICKET_STATUSES_ENUM

  TICKET_TYPES = {
    activation_request: {
        index: 1,
        need_service: true
    },
    report_a_bug: {
        index: 2,
        need_service: false
    },
    user_right_request: {
        index: 3,
        need_service: false
    },
    info_request: {
        index: 4,
        need_service: false
    },
    account_recover: {
        index: 5,
        need_service: true
    }
  }
  TICKET_TYPES_ENUM = TICKET_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum ticket_type: TICKET_TYPES_ENUM

  belongs_to  :user
  belongs_to  :service

  has_many :comments, as: :commentable

  validates :subject, presence: true, length: {minimum: 2, maximum: 255}
  validates :user, presence: true
  validates :ticket_type, presence: true
  validates :ticket_status, presence: true
  validates :service_id, presence: true, if: Proc.new {TICKET_TYPES[self.ticket_type.to_sym][:need_service]}

  scope :owned, ->(user) { where(user: user) }
  scope :by_type, ->(ticket_type) { where(ticket_type: ticket_type) }
  scope :owned_by_type, ->(user, ticket_type) { where(user: user, ticket_type: ticket_type) }
  scope :not_closed, -> { where.not(ticket_status: :closed) }
  scope :closed, -> { where(ticket_status: :closed) }
  scope :activation_requests_by_service, ->(service) { where(service: service, ticket_type: :activation_request) }

  def is_closed?
    self.ticket_status.to_sym == :closed
  end
end
