class TicketsController < ApplicationController

  before_action :authenticate_user!
  before_action :load_ticket, only: [:show, :edit, :update, :destroy]


  def index
    @collection = current_user.tickets
  end

  def show
    @comments = Comment.where(commentable: @ticket).order(created_at: :desc)
    @comment = Comment.new(commentable: @ticket)
  end

  def new
    @ticket = Ticket.new
    @ticket.user = current_user
    @new_comment = Comment.new(body: params[:new_comment])
  end

  def create
    @ticket = Ticket.new
    @ticket.user = current_user
    @ticket.ticket_status = Ticket::TICKET_STATUSES[:opened]
    @ticket.assign_attributes(ticket_params)
    begin
      Ticket.transaction do
        @ticket.save!
        Comment.create(commentable: @ticket, user: current_user, body: params[:new_comment]) unless params[:new_comment].blank?
      end
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.ticket'))
      redirect_to_show
    rescue
      @new_comment = Comment.new(body: params[:new_comment])
      render :new
    end
  end

  def edit
    @new_comment = Comment.new(body: params[:new_comment])
  end

  def update
    @ticket.assign_attributes(ticket_params)
    @ticket.ticket_status = Ticket::TICKET_STATUSES[:opened]
    begin
      Ticket.transaction do
        @ticket.save!
        Comment.create(commentable: @ticket, user: current_user, body: params[:new_comment]) unless params[:new_comment].blank?
      end
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.ticket'))
      redirect_to_show
    rescue
      @new_comment = Comment.new(body: params[:new_comment])
      render :edit
    end
  end

  def destroy
    if @ticket.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.ticket'))
      redirect_to_index
    else
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

end
