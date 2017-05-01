class ErrorMeasurement < ApplicationRecord

  ERROR_TYPES = {
      proxy_initialization_error: {
          index: 1
      },
      proxy_authentication_error: {
          index: 2
      },
      proxy_redirection_error: {
          index: 3
      },
      proxy_request_error: {
          index: 4
      },
      proxy_missing_mandatory_quer_parameter_error: {
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
