class TicketNotifier < ApplicationMailer

  def send_ticket_notification(ticket, action, user)
    @ticket = ticket
    locale = user.try(:language) || I18n.default_locale
    I18n.with_locale(locale) do
      @action_name = I18n.t("tickets.actions.#{action}.title")
      @status_name = I18n.t("types.ticket_statuses.#{ticket.ticket_status}.title")
      mail( to: user.email,
            subject: I18n.t("mailer.ticket_notifier.send_ticket_notification.subject", status: @status_name, action: @action_name, ticket_name: @ticket.subject) )
    end
  end

end
