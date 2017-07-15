class ServiceNotifier < ApplicationMailer
  def send_validation(service)
    @service = service
    user = @service.main_admin.email
    locale = user.try(:language) || I18n.default_locale
    I18n.with_locale(locale) do
      mail( :to => user.email,
            :subject => I18n.t('mailer.service_notifier.send_validation.subject') )
    end
  end
end
