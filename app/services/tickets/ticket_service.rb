module Tickets
  class TicketService
    def initialize(ticket)
      @ticket = ticket
    end

    def open
      begin
        Ticket.transaction do
          @ticket.ticket_status = :opened
          @ticket.save!
          send_action_notification(:open)
        end
        true
      rescue
        false
      end
    end

    def edit(comment_body)
      begin
        Ticket.transaction do
          old_status = @ticket.ticket_status
          set_in_progress
          @ticket.save!
          Comment.create!(commentable: @ticket, user: @ticket.user, body: comment_body) unless comment_body.blank?
          send_action_notification(:edit) if old_status != @ticket.ticket_status
        end
        true
      rescue
        false
      end
    end

    def create(comment_body)
      begin
        Ticket.transaction do
          @ticket.ticket_status = :opened
          @ticket.save!
          Comment.create!(commentable: @ticket, user: @ticket.user, body: comment_body) unless comment_body.blank?
          send_action_notification(:create)
        end
        true
      rescue
        false
      end
    end

    def comment(comment_body)
      begin
        Ticket.transaction do
          Comment.create!(commentable: @ticket, user: @ticket.user, body: comment_body) unless comment_body.blank?
          send_action_notification(:comment)
        end
        true
      rescue
        false
      end
    end

    def close
      begin
        Ticket.transaction do
          @ticket.ticket_status = :closed
          @ticket.save!
          send_action_notification(:close)
        end
        true
      rescue
        false
      end
    end

    def send_activation_request
      @ticket.ticket_type = :activation_request
      @ticket.subject = I18n.t("tickets.default_subjects.activation_request", name: @ticket.service.name)
      create(I18n.t("tickets.default_subjects.activation_request", name: @ticket.service.name))
    end

    private

    def set_in_progress
      @ticket.ticket_status = :in_progress
    end

    def send_action_notification(action)
      list_user = Ticket::TICKET_STATUSES[@ticket.ticket_status.to_sym][:notifications]
      TicketNotifier.send_ticket_notification(@ticket, action, list_user).deliver_now
    end
  end
end