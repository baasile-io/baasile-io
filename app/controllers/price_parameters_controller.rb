class PriceParametersController < ApplicationController
  before_action :authenticate_user!
  before_action :init
  before_action :load_contract
  before_action :is_commercial?
  before_action :load_company
  before_action :load_service_and_authorize!
  before_action :load_proxy
  before_action :load_price_and_authorize!
  before_action :load_price_parameter, only: [:show, :edit, :update, :destroy, :toogle_activate]
  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy) unless current_proxy.nil?
    add_breadcrumb current_price.name, service_proxy_price_path(current_service, current_proxy, current_price) unless current_proxy.nil?
  end

  def index
    @collection = PriceParameter.where(price: @price, attached: false)
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
    if @price_parameter.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.@price_parameter'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
    @form_values = get_form_values
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

  def get_form_values
    return [current_service, current_proxy, @price, @price_parameter] if @contract.nil?
    return [@company, @contract, @price, @price_parameter] unless @company.nil?
    return [current_service, @contract, @price, @price_parameter] unless @service.nil?
    return [@contract, @price, @price_parameter]
  end

  def init
    @contract = nil
    @company = nil
    @service = nil
    @proxy = nil
  end

  def redirect_to_index
    return redirect_to service_proxy_price_path(current_service, current_proxy, @price) if @contract.nil?
    return redirect_to company_contract_path(current_company, @contract) unless @companie.nil?
    return redirect_to service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to contract_path(@contract)
  end

  def redirect_to_show
    return redirect_to service_proxy_price_path(current_service, current_proxy, @price) if @contract.nil?
    return redirect_to company_contract_path(current_company, @contract) unless @companie.nil?
    return redirect_to service_contract_path(current_service, @contract) unless @service.nil?
    return redirect_to contract_path(@contract)
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
    unless @contract.nil?
      if params.key?(:service_id)
        @service = Service.find(params[:service_id])
      else
        @service = nil
      end
    else
      if params.key?(:service_id)
        @service = Service.find(params[:service_id])
        return head(:forbidden) unless is_commercial_of_current_service?
      else
        return head(:forbidden)
      end
    end
  end

  def load_proxy
    if params.key?(:proxy_id)
      @proxy = Proxy.find(params[:proxy_id])
    else
      @proxy = nil
    end
  end

  def is_commercial_of_current_service?
    current_user.has_role?(:superadmin) || current_user.has_role?( :commercial, current_service)
  end

  def price_parameter_params
    allowed_parameters = [:name, :price_parameters_type, :parameter, :nb_free, :reset_free_perode_hour, :cost]
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

  def current_proxy
    return nil unless params[:proxy_id]
    @proxy
  end

  def load_company
    unless @contract.nil?
      if params.key?(:company_id)
        @company = Company.find(params[:company_id])
      else
        @company = nil
      end
    end
  end

  def load_contract
    if params.key?(:contract_id)
      @contract = Contract.find(params[:contract_id])
    else
      @contract = nil
    end
  end

  def current_price
    return nil unless params[:price_id]
    @price
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
end