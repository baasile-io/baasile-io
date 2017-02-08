class ServicesController < ApplicationController
  before_action :check_current_user_is_active
  before_action :authenticate_user!
  before_action :load_service_and_authorize_with_admin_company, only: [:activate, :deactivate]
  before_action :load_service_and_authorize, only: [:show, :edit, :update, :destroy, :public_set, :public_unset]
  before_action :superadmin, only: [:set_right, :unset_right, :admin_board, :destroy, :public_set, :public_unset]
  before_action :load_companies, only: [:edit, :update, :new, :new_client, :create]
  before_action :admin_superadmin_authorize, only: [:activate, :deactivate]

  def index
    @collection = Service.authorized(current_user).where(service_type: :startup)
  end

  def show
  end

  def new
    @service = Service.new
    @service.company_id = params[:company_id]
    @service.service_type = params[:service_type].to_i if params[:service_type]
    @service.build_contact_detail
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
    @service.build_contact_detail if @service.contact_detail.nil?
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
    else
      ServiceNotifier.send_validation(@service).deliver_now
    end
    redirect_back fallback_location: service_path(@service)
  end

  def deactivate
    unless @service.deactivate
      flash[:error] = I18n.t('errors.an_error_occured')
    end
    redirect_back fallback_location: service_path(@service)
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
    allowed_parameters = [:name, :service_type, :description, contact_detail_attributes: [:name, :siret, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone]]
    allowed_parameters += [:subdomain, :company_id, :public] if current_user.has_role?(:superadmin)
    params.require(:service).permit(allowed_parameters)
  end

  def load_companies
    @companies = Company.authorized(current_user)
  end

  def load_service_and_authorize
    @service = Service.find_by_id(params[:id])
    return redirect_to services_path if @service.nil?
    unless @service.authorized?(current_user)
      return head(:forbidden)
    end
  end

  def load_service_and_authorize_with_admin_company
    @service = Service.find_by_id(params[:id])
    return redirect_to services_path if @service.nil?
    unless @service.associated?(current_user) || @service.authorized?(current_user)
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
  def superadmin
    return head(:forbidden) unless current_user.has_role?(:superadmin)
  end

  def admin_superadmin_authorize
    return head(:forbidden) unless current_user.is_superadmin? || current_user.has_role?(:admin, @service.company)
  end

  def current_module
    'dashboard'
  end

end
