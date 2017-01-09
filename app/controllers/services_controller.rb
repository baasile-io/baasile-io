class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize, only: [:show, :edit, :update, :destroy]

  def index
    @collection = Service.authorized(current_user)
  end

  def show
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new
    @service.user = current_user
    @service.assign_attributes(service_params)

    if @service.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.service'))
      redirect_to service_path(@service)
    else
      flash[:error] = @service.errors.messages
      render :new
    end
  end

  def edit
  end

  def update
    @service.assign_attributes(service_params)

    if @service.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
      redirect_to service_path(@service)
    else
      flash[:error] = @service.errors.messages
      render :edit
    end
  end

  def destroy
    if @service.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      redirect_to services_path
    else
      flash[:error] = @service.errors.messages
      render :show
    end
  end

  def activate
    return head(:forbidden) unless current_user.has_role?(:superadmin)

    @service = Service.find(params[:id])

    unless @service.is_activable?
      flash[:error] = I18n.t('activerecord.validations.service.missing_subdomain')
    else
      ActivateServiceJob.perform_later @service.id
    end

    redirect_to service_path(@service)
  end

  def deactivate
    return head(:forbidden) unless current_user.has_role?(:superadmin)

    if @service = Service.find_by_id(params[:id])
      DeactivateServiceJob.perform_later @service.id
      redirect_to service_path(@service)
    end
  end

  def set_right
    return head(:forbidden) unless current_user.has_role?(:superadmin)
    service_owner = Service.find(params[:id])
    service_targeted = Service.find(params[:target_id])
    service_owner.add_role(:all, service_targeted)
    redirect_to admin_board_service_path(params[:id])
  end

  def unset_right
    return head(:forbidden) unless current_user.has_role?(:superadmin)
    service_owner = Service.find(params[:id])
    service_targeted = Service.find(params[:target_id])
    service_owner.remove_role :all, service_targeted
    redirect_to admin_board_service_path(params[:id])
  end

  def admin_board
    return head(:forbidden) unless current_user.has_role?(:superadmin)
    @collection = Service.where.not(id: params[:id])
    @service = Service.find_by_id(params[:id])
  end

  private

  def service_params
    allowed_parameters = [:name, :description]
    allowed_parameters << :subdomain if current_user.has_role?(:superadmin)
    params.require(:service).permit(allowed_parameters)
  end

  def load_service_and_authorize
    @service = Service.find_by_id(params[:id])
    return redirect_to services_path if @service.nil?
    unless @service.authorized?(current_user)
      return head(:forbidden)
    end
  end

  def is_admin_of(service)
    return @service.has_role? :all, service
  end

  helper_method :is_admin_of
end
