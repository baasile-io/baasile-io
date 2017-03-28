class PricesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service
  before_action :load_contract
  before_action :load_proxy
  before_action :load_price, except: [:new, :create, :index]
  before_action :load_price_parameters, only: [:show]

  # Authorization
  before_action :authorize_action
  before_action :authorize_contract_set_prices

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service) unless current_service.nil?
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path unless current_service.nil?
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy) if current_proxy
  end

  def index
    @collection = Price.templates(current_proxy)
  end

  def new
    @price = Price.new
    @form_values = get_form_values
  end

  def create
    @price = Price.new
    @price.user = current_user
    @price.service = current_service
    @price.proxy = current_proxy
    @price.assign_attributes(price_params)
    if @price.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.price'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :new
    end
  end

  def edit
    @form_values = get_form_values
  end

  def update
    @price.assign_attributes(price_params)
    if @price.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.price'))
      redirect_to_show
    else
      @form_values = get_form_values
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
      redirect_to_show
    end
  end

  private

  def get_form_values
    return [current_service, current_proxy, @price] if @contract.nil?
    return [@company, @contract, @price] unless @company.nil?
    return [current_service, @contract, @price] unless @service.nil?
    return [@contract, @price]
  end

  def load_price_parameters
    @price_parameters = @price.price_parameters
  end

  def redirect_to_index
    return redirect_to service_proxy_prices_path(current_service, current_proxy) if @contract.nil?
    return redirect_to prices_service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to prices_contract_path(@contract)
  end

  def redirect_to_show
    return redirect_to service_proxy_price_path(current_service, current_proxy, @price) if @contract.nil?
    return redirect_to prices_service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to prices_contract_path(@contract)
  end

  def load_service
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    end
  end

  def load_contract
    if params.key?(:contract_id)
      @contract = Contract.find(params[:contract_id])
    end
  end

  def load_proxy
    if params.key?(:proxy_id)
      @proxy = Proxy.find(params[:proxy_id])
    end
  end

  def load_price
    if params.key?(:id)
      @price = Price.find(params[:id])
    end
  end

  def price_params
    allowed_parameters = [:name, :base_cost, :free_hour, :cost_by_time]
    params.require(:price).permit(allowed_parameters)
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_service
    @service
  end

  def current_contract
    return nil unless params[:contract_id]
    @contract
  end

  def current_price
    return nil unless params[:id]
    @price
  end

  def current_proxy
    return nil unless params[:proxy_id]
    @proxy
  end

  def current_module
    def current_module
      if !@company.nil?
        'companies'
      elsif !@service.nil?
        'dashboard'
      else
        'contract'
      end
    end
  end

  def current_authorized_resource
    current_service
  end
end