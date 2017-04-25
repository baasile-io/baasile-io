module Tickets
  class TicketService
    def initialize(ticket)
      @ticket = ticket
    end

    def set_in_progress
      if @ticket.ticket_status.to_sym == :opened
        begin
          @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:in_progress]
          @ticket.save
          return true
        rescue
          return false
        end
      end
      return false
    end

    def open
      begin
        Ticket.transaction do
          @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:opened]
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
          @ticket.save!
          Comment.create!(commentable: @ticket, user: @ticket.user, body: comment_body) unless comment_body.blank?
          send_action_notification(:edit)
        end
        true
      rescue
        false
      end
    end

    def create(comment_body)
      begin
        Ticket.transaction do
          @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:opened]
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
          @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:closed]
          @ticket.save!
          send_action_notification(:close)
        end
        true
      rescue
        false
      end
    end

    private

    def send_action_notification(action)
      list_user = Ticket::TICKET_STATUSES[@ticket.ticket_status.to_sym][:notifications]
      TicketNotifier.send_ticket_notification(@ticket, action, list_user).deliver_now
    end
  end
end