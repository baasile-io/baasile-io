class TicketNotifier < ApplicationMailer

  def send_ticket_notification(ticket, action, list_users, current_user)
    @ticket = ticket
    users_to_be_notified(ticket, list_users, current_user).each do |user|
      if (user.is_active_notification_ticket)
        locale = user.try(:language) || I18n.default_locale
        I18n.with_locale(locale) do
          @action_name = I18n.t("tickets.actions.#{action}.title")
          @status_name = I18n.t("types.ticket_statuses.#{ticket.ticket_status}.title")
          mail( to: user.email,
                subject: I18n.t("mailer.ticket_notifier.send_ticket_notification.subject", status: @status_name, action: @action_name, ticket_name: @ticket.subject) )
        end
      end
    end
  end

  def users_to_be_notified(ticket, list_users, current_user)
    list_res_of_users = []
    list_users.each do |user_scope|
      user = ticket.send(user_scope.to_s)
      list_res_of_users << user if current_user.id != user.id
    end.reject(&:blank?).uniq
    return list_res_of_users
  end
end
