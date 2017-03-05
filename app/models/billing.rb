class Billing < ApplicationRecord

  belongs_to :service
  belongs_to :user
  has_many :BillingByParametersCalls
  has_many :contracts

  validates :name, presence: true
  validates :user, presence: true
  validates :service, presence: true

  scope :owned, ->(user) { where(user: user) }

end
