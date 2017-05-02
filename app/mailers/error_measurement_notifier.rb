class ErrorMeasurementNotifier < ApplicationMailer

  def send_error_measurement_notification(error_measurement)
    @error_measurement = error_measurement
    users_to_be_notified(@error_measurement).each do |user|
      locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(locale) do
        @error_measurement_title = I18n.t("errors.api.#{@error_measurement.error_type.underscore}.title")
        @error_measurement_message = I18n.t("errors.api.#{@error_measurement.error_type.underscore}.message")
        mail( to: user.email,
              subject: I18n.t("mailer.ticket_notifier.send_ticket_notification.subject", title: @error_measurement_title, message: @error_measurement_message) )
      end
    end
  end

  private

  def users_to_be_notified(error_measure)
    ERROR_MEASUREMENT_TYPES[error_measure.error_type][:notifications].each_with_object([]) do |(user_scope, user_roles), users|
      users += get_users_by_startup_or_client_path_by_scope(error_measure.route.service, error_measure.contract.client, user_scope, user_roles)
    end.reject(&:blank?).uniq
  end

  # todo généraliser pour mettre dans un service user par exemple

  def get_users_by_startup_or_client_path_by_scope(startup_path, client_path, user_scope, user_roles)
    return get_users_by_service_by_scopes(startup_path, user_roles) if user_scope == :startup
    return get_users_by_service_by_scopes(client_path, user_roles) if user_scope == :client
  end

  def get_users_by_service_by_scopes(service_path, user_roles)
    user_roles.each([]) do |user_role, users|
      users << service_path.send("main_#{user_role}")
    end.reject(&:blank?).uniq
  end

end
