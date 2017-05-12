class ErrorMeasurementNotifier < ApplicationMailer

  def send_error_measurement_notification(error_measurement, notifications_scope)
    @error_measurement = error_measurement
    users_to_be_notified(notifications_scope).each do |user|
      @user = user
      locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(locale) do
        @error_measurement_title = I18n.t("errors.api.#{@error_measurement.error_code}.title", locale: :en)
        @error_measurement_message = I18n.t("errors.api.#{@error_measurement.error_code}.message", locale: :en)
        mail( to: user.email,
              subject: I18n.t("mailer.error_measurement_notifier.send_error_measurement_notification.subject", title: @error_measurement_title) )
      end
    end
  end

  private

  def users_to_be_notified(notifications_scope)
    return [] if notifications_scope.keys.size == 0
    notifications_scope.each_with_object([]) do |(user_scope, user_roles), user_array|
      user_array.concat(
        get_users_by_service_and_by_roles(
          (user_scope == :startup ? @error_measurement.route.service : @error_measurement.contract.client),
          user_roles
        )
      )
    end.reject(&:blank?).uniq
  end

  # TODO généraliser pour mettre dans un service user par exemple
  def get_users_by_service_and_by_roles(service, user_roles)
    user_roles.each_with_object([]) do |user_role, users|
      users << service.send("main_#{user_role}")
    end.reject(&:blank?).uniq
  end

end
