class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :public_set, :public_unset]
  before_action :is_super_admin, only: [:activate, :deactivate, :set_right, :unset_right, :admin_board]
  before_action :load_companies, only: [:edit, :new]

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
      render :edit
    end
  end

  def destroy
    if @service.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      redirect_to services_path
    else
      render :show
    end
  end

  def activate
    unless @service.activate
      flash[:error] = I18n.t('activerecord.validations.service.missing_subdomain')
      redirect_to edit_service_path(@service)
    else
      ServiceNotifier.send_validation(@service).deliver_now
      redirect_to service_path(@service)
    end
  end

  def deactivate
    unless @service.deactivate
      flash[:error] = I18n.t('errors.an_error_occured')
    end
    redirect_to service_path(@service)
  end

  def public_set
    @service.public = true
    if @service.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.service'))
    end
    redirect_to service_path(@service)
  end

  def public_unset
    @service.public = false
    if @service.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.service'))
    end
    redirect_to service_path(@service)
  end

  private

  def service_params
    allowed_parameters = [:name, :description, :public, :company_id]
    allowed_parameters << :subdomain if current_user.has_role?(:superadmin)
    params.require(:service).permit(allowed_parameters)
  end

  def load_companies
    @companies = Company.all
  end

  def load_service_and_authorize
    @service = Service.find_by_id(params[:id])
    return redirect_to services_path if @service.nil?
    unless @service.authorized?(current_user)
      return head(:forbidden)
    end
  end

  def current_service
    return nil unless params[:id]
    @service
  end

  def is_admin_of(service)
    return @service.has_role? :all, service
  end

  helper_method :is_admin_of
  def is_super_admin
    return head(:forbidden) unless current_user.has_role?(:superadmin)
  end

end
