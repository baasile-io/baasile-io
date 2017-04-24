module BackOffice
  class TicketsController < BackOfficeController
    before_action :load_ticket, only: [:edit, :update, :destroy, :closed]
    before_action :set_ticket_in_progress, only: [:edit, :update, :destroy]

    def index
      @collection = Ticket.not_closed
    end

    def edit
      @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
      @comment = Comment.new(commentable: @ticket)
    end

    def update
      @ticket.assign_attributes(ticket_params)
      if @ticket.save
        Comment.create(commentable: @ticket, user: current_user, body: params[:new_comment]) unless params[:new_comment].blank?
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
        redirect_to_edit
      else
        @new_comment = Comment.new(body: params[:new_comment])
        render :edit
      end
    end

    def closed
      @ticket.ticket_status = Ticket::TICKET_STATUSES[:closed]
      if @ticket.save
        @ticket.save
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
        @ticket.ticket_status = Ticket::TICKET_STATUSES[:in_progress]
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

  end
end