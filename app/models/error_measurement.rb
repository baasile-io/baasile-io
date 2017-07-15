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
  belongs_to  :client,      class_name: Service.name

  has_one     :proxy,       through: :route
  has_one     :startup,     through: :route, source: :service

  validates   :error_type,  presence: true
  validates   :client,      presence: true
  validates   :route,       presence: true

  scope :old, -> {
    where("created_at <= ?", DateTime.now - Appconfig.get(:error_measurement_backup_duration).days)
  }

  def to_s
    "#{self.error_code} #{I18n.t("errors.api.#{self.error_code}.title", locale: :en)}"
  end

  def message
    I18n.t("errors.api.#{self.error_code}.message", locale: :en)
  end
end
