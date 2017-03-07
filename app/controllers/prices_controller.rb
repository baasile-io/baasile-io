class PricesController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_service_and_authorize!
  before_action :load_price, only: [:show, :edit, :update, :destroy, :toogle_activate]
  before_action :load_price_parameters, only: [:show]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
  end

  def index
    @collection = Price.where(service: current_service, attached: false)
  end

  def new
    @price = Price.new
  end

  def create
    @price = Price.new
    @price.user = current_user
    @price.service = current_service
    @price.assign_attributes(price_params)
    if @price.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.price'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
  end

  def update
    @price.assign_attributes(price_params)
    if @price.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.price'))
      redirect_to_show
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @price.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.price'))
      redirect_to_index
    else
      render :show
    end
  end

  def toogle_activate
    @price.activate = !@price.activate
    @price.save
    redirect_to_show
  end

  private

  def load_price_parameters
    @price_parameters = PriceParameter.where(price_id: @price.id, attached: false)
  end

  def redirect_to_index
    return redirect_to service_prices_path(current_service)
  end

  def redirect_to_show
    return redirect_to service_price_path(current_service, @price)
  end

  def load_price
    @price = Price.find(params[:id])
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

  def price_params
    allowed_parameters = [:name, :base_cost, :free_hour, :cost_by_time]
    params.require(:price).permit(allowed_parameters)
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

  def current_module
      'dashboard'
  end
end