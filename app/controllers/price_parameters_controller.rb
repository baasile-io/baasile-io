class PriceParametersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service
  before_action :load_contract
  before_action :load_proxy
  before_action :load_price
  before_action :load_price_parameter, except: [:index, :new, :create]
  before_action :load_route_and_query_parameters, only: [:new, :edit, :update, :create]
  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  # Authorization
  before_action :authorize_action
  before_action :authorize_contract_set_prices

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service) unless current_service.nil?
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path unless current_service.nil?
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy) unless current_proxy.nil?
    add_breadcrumb current_price.name, service_proxy_price_path(current_service, current_proxy, current_price) unless current_proxy.nil?
  end

  def index
    return redirect_to_show if current_contract
    @collection = @price.price_parameters
  end

  def new
    @price_parameter = PriceParameter.new
    @form_values = get_form_values
  end

  def create
    @price_parameter = PriceParameter.new
    @price_parameter.user = current_user
    @price_parameter.price = current_price
    @price_parameter.assign_attributes(price_parameter_params)
    unless @price_parameter.query_parameter_id.nil?
      if @price_parameter.query_parameter.route_id != @price_parameter.route_id
        flash[:error] = I18n.t('actions.destroy')
        @form_values = get_form_values
        return render :new
      end
      @price_parameter.parameter = @price_parameter.route.name + " - " + @price_parameter.query_parameter.name unless @price_parameter.route.nil?
    else
      @price_parameter.parameter = @price_parameter.route.name + " - all" unless @price_parameter.route.nil?
    end
    if @price_parameter.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.price_parameter'))
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
    @price_parameter.assign_attributes(price_parameter_params)
    if @price_parameter.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.price_parameter'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :edit
    end
  end

  def show
    redirect_to_show
  end

  def destroy
    if @price_parameter.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.price_parameter'))
      redirect_to_index
    else
      redirect_to_show
    end
  end

  private

  def get_form_values
    return [current_service, current_proxy, @price, @price_parameter] if @contract.nil?
    return [@company, @contract, @price, @price_parameter] unless @company.nil?
    return [current_service, @contract, @price, @price_parameter] unless @service.nil?
    return [@contract, @price, @price_parameter]
  end

  def redirect_to_index
    return redirect_to service_proxy_price_path(current_service, current_proxy, @price) if @contract.nil?
    return redirect_to prices_service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to prices_contract_path(@contract)
  end

  def redirect_to_show
    return redirect_to service_proxy_price_path(current_service, current_proxy, @price) if @contract.nil?
    return redirect_to prices_service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to prices_contract_path(@contract)
  end

  def load_route_and_query_parameters
    proxy = current_contract.nil? ? current_proxy : current_contract.proxy
    @routes = proxy.routes
    @query_parameters = proxy.query_parameters
  end

  def load_price_parameter
    @price_parameter = PriceParameter.find(params[:id])
  end

  def load_price
    @price = Price.find(params[:price_id])
  end

  def load_proxy
    if @contract.nil?
      if params.key?(:proxy_id)
       @proxy = Proxy.find(params[:proxy_id])
      end
    else
      @proxy = @contract.proxy
    end
  end

  def load_contract
    if params.key?(:contract_id)
      @contract = Contract.find(params[:contract_id])
    end
  end

  def load_service
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    end
  end

  def price_parameter_params
    params.require(:price_parameter).permit([:route_id, :query_parameter_id, :price_parameters_type, :free_count, :cost])
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

  def current_contract
    return nil unless params[:contract_id]
    @contract
  end

  def current_proxy
    return nil unless params[:proxy_id]
    @proxy
  end

  def current_price
    return nil unless params[:price_id]
    @price
  end

  def current_module
    def current_module
      if !@service.nil?
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