class BillingByParametersCall < ApplicationRecord

  belongs_to :Billing

  validates :name, presence: true

end
