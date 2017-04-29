class TicketsController < ApplicationController

  before_action :authenticate_user!
  before_action :load_ticket, only: [:show, :edit, :update, :destroy, :add_comment]
  before_action :load_tickets, only: [:index]
  before_action :load_closed_tickets, only: [:closed]
  before_action :load_comments, only: [:show, :edit, :update, :destroy, :add_comment]

  def add_comment
    ticket_service = Tickets::TicketService.new(@ticket)
    if ticket_service.comment(params[:new_comment])
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
      redirect_to_show
    else
      flash[:error] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
      @new_comment = Comment.new(body: params[:new_comment])
      render :show
    end
  end

  def closed
  end

  def index
  end

  def show
    @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
    @new_comment = Comment.new(commentable: @ticket, body: params[:new_comment])
  end

  def new
    @ticket = Ticket.new
    @ticket.user = current_user
    @new_comment = Comment.new(commentable: @ticket, body: params[:new_comment])
  end

  def create
    @ticket = Ticket.new
    @ticket.user = current_user
    @ticket.assign_attributes(ticket_params)
    ticket_service = Tickets::TicketService.new(@ticket)
    if ticket_service.create(params[:new_comment])
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.ticket'))
      redirect_to_index
    else
      flash[:error] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
      @new_comment = Comment.new(commentable: @ticket, body: params[:new_comment])
      render :new
    end
  end

  def update
    @ticket.assign_attributes(ticket_params)
    @ticket.ticket_status = Ticket::TICKET_STATUSES_ENUM[:opened]
    ticket_service = Tickets::TicketService.new(@ticket)
    if ticket_service.edit(params[:new_comment])
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
      redirect_to_show
    else
      flash[:error] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
      @new_comment = Comment.new(body: params[:new_comment])
      render :edit
    end
  end

  def destroy
    if @ticket.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.ticket'))
      redirect_to_index
    else
      flash[:error] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
      render :show
    end
  end

private

  def redirect_to_show
    return redirect_to ticket_path(@ticket)
  end

  def redirect_to_index
    return redirect_to tickets_path
  end

  def ticket_params
    allowed_parameters = [:subject, :ticket_type, :service]
    params.require(:ticket).permit(allowed_parameters)
  end

  def load_ticket
    @ticket = Ticket.find(params[:id])
  end

  def load_tickets
    @collection = current_user.tickets.not_closed.order(updated_at: :desc)
  end

  def load_closed_tickets
    @collection = current_user.tickets.closed.order(updated_at: :desc)
  end


  def load_comments
    @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
    @new_comment = Comment.new(body: params[:new_comment])
  end

end
