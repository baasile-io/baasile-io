class ErrorMeasurement < ApplicationRecord

  ERROR_TYPES = {
      proxyInitializationError: {
          index: 1
      },
      proxyAuthenticationError: {
          index: 2
      },
      proxyRedirectionError: {
          index: 3
      },
      proxyRequestError: {
          index: 4
      },
      proxyMissingMandatoryQueryParameterError: {
          index: 5
      }
  }

  ERROR_TYPES_ENUM = ERROR_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum error_type: ERROR_TYPES_ENUM

  belongs_to  :contract
  belongs_to  :route

  has_one :startup, through: :contract
  has_one :client, through: :contract
  has_one :proxy, through: :contract

  validates   :error_type , presence: true
  validates   :request    , presence: true
  validates   :contract   , presence: true
  validates   :route      , presence: true



end
