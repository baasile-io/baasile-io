class ErrorMeasurement < ApplicationRecord

  ERROR_MEASUREMENT_TYPES = {
    'proxify_concern/proxy_initialization_error' => {
      notifications: {
        startup: ["admin", "developer"]
      }
    },
    'proxify_concern/proxy_authentication_error' => {
      notifications: {
        startup: ["admin", "developer"]
      }
    },
    'proxify_concern/proxy_redirection_error' => {
      notifications: {
        startup: ["admin", "developer"]
      }
    },
    'proxify_concern/proxy_request_error' => {
      notifications: {
        startup: ["admin", "developer"]
      }
    },
    'proxify_concern/proxy_socket_error' => {
      notifications: {
        startup: ["admin", "developer"]
      }
    },
    'proxify_concern/proxy_missing_mandatory_quer_parameter_error' => {
      notifications: {
        client: ["admin", "developer"]
      }
    }
  }

  belongs_to  :contract
  belongs_to  :route

  has_one :client, through: :contract
  has_one :proxy, through: :route
  has_one :startup, through: :route, source: :proxy

  validates   :error_type , presence: true
  validates   :contract   , presence: true
  validates   :route      , presence: true

  def to_s
    "#{I18n.t("errors.api.#{self.error_type.underscore}.title")} (#{self.error_code})"
  end

  def message
    I18n.t("errors.api.#{self.error_type.underscore}.message")
  end
end
