class UserNotifier < ApplicationMailer

  def send_welcome_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    mail(to: @user.email, subject: I18n.t('mailer.user_notifier.send_welcome_email.subject'))
  end
end
