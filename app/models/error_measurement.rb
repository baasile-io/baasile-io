class ErrorMeasurement < ApplicationRecord

  ERROR_TYPE = {
      ProxyInitializationError: {
          index: 1,
          title: I18n.t("errors.ProxyInitializationError.title"),
          message: I18n.t("errors.ProxyInitializationError.message"),
      },
      ProxyAuthenticationError: {
          index: 2,
          title: I18n.t("errors.ProxyAuthenticationError.title"),
          message: I18n.t("errors.ProxyAuthenticationError.message"),
      },
      ProxyRedirectionError: {
          index: 3,
          title: I18n.t("errors.ProxyRedirectionError.title"),
          message: I18n.t("errors.ProxyRedirectionError.message"),
      },
      ProxyRequestError: {
          index: 4,
          title: I18n.t("errors.ProxyRequestError.title"),
          message: I18n.t("errors.ProxyRequestError.message"),
      },
      ProxyMissingMandatoryQueryParameterError: {
          index: 5,
          title: I18n.t("errors.ProxyMissingMandatoryQueryParameterError.title"),
          message: I18n.t("errors.ProxyMissingMandatoryQueryParameterError.message"),
      }
  }

  ERROR_TYPE_ENUM = ERROR_TYPE.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum error_type: ERROR_TYPE_ENUM

  belongs_to  :contract
  belongs_to  :route

  has_one     :startup    , throught: :contract
  has_one     :client     , throught: :contract
  has_one     :proxy      , throught: :contract

  validates   :error_type , presence: true
  validates   :request    , presence: true
  validates   :contract   , presence: true
  validates   :route      , presence: true



end
