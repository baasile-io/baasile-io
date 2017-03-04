class BillingByParametersCall < ApplicationRecord

  belongs_to :billing
  belongs_to :user

  validates :name, presence: true
  validates :billing, presence: true

end
