class ErrorMeasurement < ApplicationRecord

  belongs_to  :contract
  belongs_to  :route

  has_one :client, through: :contract
  has_one :proxy, through: :route
  has_one :startup, through: :route, source: :proxy

  validates   :error_type , presence: true
  validates   :request    , presence: true
  validates   :contract   , presence: true
  validates   :route      , presence: true

end
