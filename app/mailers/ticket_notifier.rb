class TicketNotifier < ApplicationMailer

  def send_ticket_notification(ticket, status, action)
    @ticket = ticket
    users_to_be_notified(ticket, status).each do |user|
      locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(locale) do
        @action_name = I18n.t("ticket.actions.#{action}.title")
        @status_name = I18n.t("types.ticket_statuses.#{ticket.ticket_status}.title")
        mail( to: user.email,
              subject: I18n.t("mailer.ticket_notifier.send_ticket_notification.subject", status: @status_name, action: action) )
      end
    end
  end

  private

  def users_to_be_notified(ticket, status)
    users = []
    Ticket::TICKET_STATUSES[status][:notifications].each do |user|
      if user == 'superadmin'
        users += User.with_role(:speradmin)
      else
        users << ticket.try(user.to_sym)
      end
    end.reject(&:blank?).uniq
  end

end
