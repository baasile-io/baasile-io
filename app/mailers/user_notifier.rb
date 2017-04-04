class UserNotifier < ApplicationMailer

  def send_welcome_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    mail(to: @user.email, subject: I18n.t('mailer.user_notifier.send_welcome_email.subject'))
  end

  def send_reset_password(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    mail(to: @user.email, subject: I18n.t('mailer.user_notifier.send_reset_password.subject'))
  end

  def send_notification(contract, dayleft)
    @dayleft = dayleft
    @contract = contract
    @service = contract.client
    unless @service.user.nil?
      mail( :to => @service.user.email,
            :subject => I18n.t("mailer.user_notifier.send_notification.service.subject", name: @contract.name))
    end
    @service = contract.startup
    unless @service.user.nil?
      mail( :to => @service.user.email,
            :subject => I18n.t("mailer.user_notifier.send_notification.service.subject", name: @contract.name))
    end
  end
end
