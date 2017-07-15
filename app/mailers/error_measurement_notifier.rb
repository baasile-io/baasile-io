class ErrorMeasurementNotifier < ApplicationMailer

  def send_error_measurement_notification(error_measurement, user)
    @error_measurement = error_measurement
    @user = user
    locale = @user.try(:language) || I18n.default_locale
    I18n.with_locale(locale) do
      @error_measurement_title = I18n.t("errors.api.#{@error_measurement.error_code}.title", locale: :en)
      @error_measurement_message = I18n.t("errors.api.#{@error_measurement.error_code}.message", locale: :en)
      mail( to: @user.email,
            subject: I18n.t("mailer.error_measurement_notifier.send_error_measurement_notification.subject", title: @error_measurement_title) )
    end
  end

end
