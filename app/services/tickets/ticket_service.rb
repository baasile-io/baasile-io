module Tickets
  class TicketService
    def initialize(ticket, current_user)
      @ticket = ticket
      @user = current_user
      @old_status = ticket.ticket_status
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

    def edit_and_open(comment_body)
      @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:opened]
      edit(comment_body)
    end

    def edit_and_progress(new_params, comment_body)
      @ticket.assign_attributes(new_params)
      set_in_progress if @old_status.to_sym == :opened && comment_body.present?
      edit(comment_body)
    end

    def edit(comment_body)
      begin
        Ticket.transaction do
          @ticket.save!
          unless comment_body.blank?
            Comment.create!(commentable: @ticket, user: @user, body: comment_body)
            send_action_notification(:comment)
          else
            send_action_notification(:edit) if @old_status != @ticket.ticket_status
          end
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
          Comment.create!(commentable: @ticket, user: @user, body: comment_body) unless comment_body.blank?
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
          Comment.create!(commentable: @ticket, user: @user, body: comment_body) unless comment_body.blank?
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

    def send_activation_request(user, service)
      @ticket.user = user
      @ticket.service = service
      @ticket.ticket_type = :activation_request
      @ticket.subject = I18n.t("tickets.default_subjects.activation_request", name: @ticket.service.name)
      create(I18n.t("tickets.default_subjects.activation_request", name: @ticket.service.name))
    end

    def closed_tickets_by_activation(service)
      Ticket.activation_requests_by_service(service).each do |ticket|
        @ticket = ticket
        close
      end
    end

    private

    def set_in_progress
      @ticket.ticket_status = :in_progress
    end

    def send_action_notification(action)
      list_user = Ticket::TICKET_STATUSES[@ticket.ticket_status.to_sym][:notifications]
      TicketNotifier.send_ticket_notification(@ticket, action, list_user, @user).deliver_now
    end
  end
end