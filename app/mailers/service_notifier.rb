class ServiceNotifier < ApplicationMailer

  def send_validation(service)
    @service = service
    #users = User.find_as(:developer, @service)
    users = [@service.user]
    users.each do |u|
      mail( :to => u.email,
            :subject => I18n.t('mailer.service_notifier.send_validation.subject') )
    end
  end
end
