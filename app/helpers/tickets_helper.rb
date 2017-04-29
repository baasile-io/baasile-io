module TicketsHelper
  def format_ticket_types_for_select
    Ticket::TICKET_TYPES.map do |key, _|
      [I18n.t("types.ticket_types.#{key}"), key]
    end
  end

  def format_ticket_statuses_for_select
    Ticket::TICKET_STATUSES_ENUM.map do |key, _|
      [I18n.t("types.ticket_statuses.#{key}.title"), key, {'data-class': I18n.t("types.ticket_statuses.#{key}.class")}]
    end
  end
end
