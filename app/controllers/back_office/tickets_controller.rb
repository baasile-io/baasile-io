module BackOffice
  class TicketsController < BackOfficeController
    before_action :load_ticket, only: [:edit, :update, :destroy, :close, :open, :add_comment]
    before_action :load_tickets, only: [:index]
    before_action :load_closed_tickets, only: [:closed]
    before_action :load_comments, only: [:edit, :update, :destroy, :close, :open, :add_comment]

    def add_comment
      ticket_service = Tickets::TicketService.new(@ticket, current_user)
      if ticket_service.comment(params[:new_comment])
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_edit
      else
        flash[:error] = I18n.t('errors.an_error_occured')
        render :edit
      end
    end

    def closed
    end

    def index
    end

    def edit
    end

    def update
      ticket_service = Tickets::TicketService.new(@ticket, current_user)
      if ticket_service.edit_and_progress(ticket_params, params[:new_comment])
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_edit
      else
        flash[:error] = I18n.t('errors.an_error_occured')
        render :edit
      end
    end

    def open
      ticket_service = Tickets::TicketService.new(@ticket, current_user)
      if ticket_service.open
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
      else
        flash[:error] = I18n.t('errors.an_error_occured')
      end
      redirect_to_edit
    end

    def close
      ticket_service = Tickets::TicketService.new(@ticket, current_user)
      if ticket_service.close
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_index
      else
        flash[:error] = I18n.t('errors.an_error_occured')
        redirect_to_edit
      end
    end

    def destroy
      if @ticket.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.ticket'))
      end
      redirect_to_index
    end

  private

    def redirect_to_edit
      redirect_to edit_back_office_ticket_path(@ticket)
    end

    def redirect_to_index
      if @ticket && @ticket.is_closed?
        return redirect_to closed_back_office_tickets_path
      end
      redirect_to back_office_tickets_path
    end

    def ticket_params
      allowed_parameters = [:subject, :ticket_type, :ticket_status, :service]
      params.require(:ticket).permit(allowed_parameters)
    end

    def load_ticket
      @ticket = Ticket.find(params[:id])
    end

    def load_tickets
      @collection = Ticket.not_closed.order(updated_at: :desc)
    end

    def load_closed_tickets
      @collection = Ticket.closed
    end

    def load_comments
      @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
      @new_comment = Comment.new(commentable: @ticket, body: params[:new_comment])
    end

  end
end