class ServiceNotifier < ApplicationMailer
  def send_validation(service)
    @service = service
    #users = User.find_as(:developer, @service)
    users = [@service.user]
    users.each do |u|
      if (u.is_active_notification_service_validation)
        mail( :to => u.email,
              :subject => I18n.t('mailer.service_notifier.send_validation.subject') )
      end
    end
  end
end
