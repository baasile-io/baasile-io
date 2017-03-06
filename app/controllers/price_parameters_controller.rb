class PriceParametersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_service_and_authorize!
  before_action :load_price_and_authorize!
  before_action :load_price_parameter, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb current_price.name, service_price_path(current_service, current_price)
  end

  def index
    @collection = PriceParameter.where(price: @price)
  end

  def new
    @price_parameter = PriceParameter.new
  end

  def create
    @price_parameter = PriceParameter.new
    @price_parameter.user = current_user
    @price_parameter.price = current_price
    @price_parameter.assign_attributes(price_parameter_params)
    if @price_parameter.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.@price_parameter'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
  end

  def update
    @price_parameter.assign_attributes(price_parameter_params)
    if @price_parameter.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.@price_parameter'))
      redirect_to_show
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @price_parameter.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.@price_parameter'))
      redirect_to_index
    else
      render :show
    end
  end

  def toogle_activate
    @price_parameter.activate = !@price_parameter.activate
    @price_parameter.save
    redirect_to_show
  end

  private

  def redirect_to_index
    return redirect_to service_price_path(current_service, @price)
    #return redirect_to service_price_price_parameters_path(current_service)
  end

  def redirect_to_show
    return redirect_to service_price_path(current_service, @price)
  end

  def load_price_parameter
    @price_parameter = PriceParameter.find(params[:id])
  end

  def load_price_and_authorize!
    if params.key?(:price_id)
      @price = Price.find(params[:price_id])
    else
      return head(:forbidden)
    end
  end

  def load_service_and_authorize!
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
      return head(:forbidden) unless is_commercial_of_current_service?
    else
      return head(:forbidden)
    end
  end

  def is_commercial_of_current_service?
    current_user.has_role?(:superadmin) || current_user.has_role?( :commercial, current_service)
  end

  def price_parameter_params
    allowed_parameters = [:name, :parameter, :free_call, :periode_by_h_reset_free, :cost_by_call]
    params.require(:price_parameter).permit(allowed_parameters)
  end

  def is_commercial?
    current_user.is_commercial?
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

  def current_price
    return nil unless params[:price_id]
    @price
  end

  def current_module
      'dashboard'
  end
end