module TicketsHelper
  def format_ticket_type_for_select
    Ticket::TICKET_TYPES.map do |key, _|
      ["#{I18n.t("types.ticket_types.#{key}")}", key]
    end
  end

  def format_ticket_statuses_for_select
    Ticket::TICKET_STATUSES.map do |key, _|
      ["#{I18n.t("types.ticket_statuses.#{key}")}", key]
    end
  end
end
