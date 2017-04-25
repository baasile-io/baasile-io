module BackOffice
  class TicketsController < BackOfficeController
    before_action :load_ticket, only: [:edit, :update, :destroy, :closed, :opened, :add_comment]
    before_action :set_ticket_in_progress, only: [:edit, :update, :destroy]
    before_action :load_tickets, only: [:index]
    before_action :load_closed_tickets, only: [:list_closed]
    before_action :load_comments, only: [:edit, :update, :destroy, :closed, :opened, :add_comment]
    before_action :ticket_service, except: [:index, :list_closed]

    def add_comment
      if @ticket_service.comment(params[:new_comment])
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_edit
      else
        flash[:fails] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
        render :edit
      end
    end

    def list_closed
    end

    def index
    end

    def edit
    end

    def update
      @ticket.assign_attributes(ticket_params)
      if @ticket_service.edit(params[:new_comment])
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_edit
      else
        render :edit
      end
    end

    def opened
      @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:opened]
      if @ticket_service.open
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_index
      else
        flash[:fails] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
        redirect_to_index
      end
    end

    def closed
      @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:closed]
      if @ticket_service.close
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_index
      else
        flash[:fails] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
        redirect_to_index
      end
    end

    def destroy
      if @ticket.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.ticket'))
      end
      redirect_to_index
    end

  private

    def set_ticket_in_progress
      logger.info "# status : " + @ticket.ticket_status.inspect
      if @ticket.ticket_status.to_sym == :opened
        @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:in_progress]
        logger.info "# status change : " + @ticket.ticket_status.inspect
        @ticket.save
      end
    end

    def redirect_to_edit
      return redirect_to edit_back_office_ticket_path(@ticket)
    end

    def redirect_to_index
      return redirect_to back_office_tickets_path
    end

    def ticket_params
      allowed_parameters = [:subject, :ticket_type, :ticket_status, :service]
      params.require(:ticket).permit(allowed_parameters)
    end

    def load_ticket
      @ticket = Ticket.find(params[:id])
    end

    def ticket_service
      @ticket_service = Tickets::TicketService.new(@ticket)
    end

    def load_tickets
      @collection = Ticket.not_closed
    end

    def load_closed_tickets
      @collection = Ticket.closed
    end

    def load_comments
      @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
      @new_comment = Comment.new(body: params[:new_comment])
    end

  end
end