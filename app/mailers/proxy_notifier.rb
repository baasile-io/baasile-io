class ProxyNotifier < ApplicationMailer

  def send_activate_proxy_notification(proxy)
    @proxy = proxy

    users_to_be_notified(@proxy, :activation).each do |user|
      locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(locale) do
        @proxy_name = @proxy.name
        mail( to: user.email,
              subject: I18n.t("mailer.proxy_notifier.send_activate_proxy_notification.#{@proxy.is_activate ? "activate" : "disable" }.subject", name: @proxy_name) )
      end
    end
  end

  private

  def users_to_be_notified(proxy, notification_type)
    return get_users_by_service_by_scopes(proxy.service, Proxy::PROXY_NOTIFICATION[notification_type])
  end

  def get_users_by_service_by_scopes(service_path, user_roles)
    user_roles.each_with_object([]) do |user_role, users|
       users << service_path.send("main_#{user_role}")
     end.reject(&:blank?).uniq
  end

end
