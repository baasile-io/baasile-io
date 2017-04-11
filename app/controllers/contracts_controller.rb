class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service
  before_action :load_contract, only: [:show, :edit, :update, :destroy, :validate, :reject, :toogle_activate, :toggle_production, :comments, :prices, :select_price, :cancel]
  before_action :load_price, only: [:show]
  before_action :load_active_services, only: [:new, :edit, :create, :update]
  before_action :load_active_client, only: [:new, :edit, :create, :update]
  before_action :load_active_proxies, only: [:new, :edit, :update, :create]

  # Authorization
  before_action :authorize_action
  before_action :authorize_contract_action

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('contracts.index.title'), :contracts_path
    #add_breadcrumb current_service.name, contract_path(curr) if current_service
  end

  def index
    unless current_service.nil?
      @collection = Contract.associated_service(current_service).order(status: :asc)
    else
      @collection = Contract.associated_user(current_user).order(status: :asc)
    end
  end

  def new
    @current_status = Contract::CONTRACT_STATUSES[:creation]
    @contract = Contract.new
    @contract.client = current_service if !current_service.nil? && current_service.is_client?
    @contract.startup = current_service if !current_service.nil? && current_service.is_startup?
    @contract.proxy_id = params[:proxy_id] if params[:proxy_id].present?
    define_form_value
  end

  def create
    @current_status = Contract::CONTRACT_STATUSES[:creation]
    @contract = Contract.new
    @contract.user = current_user
    @contract.assign_attributes(contract_params(:creation))
    @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
    @contract.status = Contract.statuses[:creation]
    if @contract.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
      define_form_value
      render :new
    end
  end

  def edit
    define_form_value
  end

  def update
    @contract.assign_attributes(contract_params(@contract.status))
    @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
      define_form_value
      render :edit
    end
  end

  def show
  end

  def destroy
    if @contract.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.contract'))
      redirect_to_index
    else
      render :show
    end
  end

  def validate
    status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
    @contract.status = status[:next] unless status[:next].nil?
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    end
    redirect_to_show
  end

  def reject
    status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
    @contract.status = status[:prev] unless status[:prev].nil?
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      unless @contract.can?(current_user, :show)
        return redirect_to_index
      end
    end
    redirect_to_show
  end

  def toggle_production
    if @contract.can?(current_user, :toggle_production)
      @contract.production = !@contract.production
      if @contract.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      end
    else
      flash[:error] = I18n.t('misc.not_authorized')
    end
    redirect_to_show
  end

  def cancel
    @contract.status = :deletion
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      return redirect_to_index
    end
    redirect_to_show
  end

  def prices
    @price_templates = Price.templates(@contract.proxy)
  end

  def select_price
    @contract.price.try(:destroy)

    price_id = params[:price_id]
    if price_id
      @contract.set_dup_price(price_id)
    else
      @contract.create_price(user: current_user)
    end

    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    end

    return redirect_to prices_service_contract_path(current_service, @contract) unless current_service.nil?
    redirect_to prices_contract_path(@contract)
  end

  def define_form_value
    @form_values = get_for_values
  end

  def comments
    @comments = Comment.where(commentable: @contract).order(created_at: :desc)
    @comment = Comment.new(commentable: @contract)
  end

  private

  def get_for_values
    return [current_service, @contract] unless current_service.nil?
    return [@contract]
  end

  def load_price
    unless @contract.price.nil?
      @price = @contract.price
      @price_parameters = PriceParameter.where(price: @price)
    end
  end

  def redirect_to_index
    return redirect_to service_contracts_path(current_service) unless current_service.nil?
    return redirect_to contracts_path
  end

  def redirect_to_show
    return redirect_to service_contract_path(current_service, @contract) unless current_service.nil?
    return redirect_to contract_path(@contract)
  end

  def load_contract
    @contract = Contract.find(params[:id])
    @current_status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
  end

  def load_active_services
    if current_contract && current_contract.persisted?
      @services = [current_contract.startup]
    else
      @services = Service.activated_startups
    end
  end

  def load_active_client
    @clients = Service.activated_clients
  end

  def load_active_proxies
    @proxies = []
    @services.each do |service|
      service.proxies.each do |proxy|
        @proxies << proxy if proxy.public || proxy.service.id == current_service.id || (current_contract && current_contract.proxy_id == proxy.id)
      end
    end
    if @proxies.count == 0
      redirect_to_index
    end
  end

  def load_service
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    else
      @service = nil
    end
  end

  def contract_params_price
    allowed_parameters = [:price_id]
    params.require(:contract).permit(allowed_parameters)
  end

  def contract_params(status)
    allowed_parameters = Contract::CONTRACT_STATUSES[status.to_sym][:allowed_parameters]
    params.require(:contract).permit(allowed_parameters)
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

  def current_contract
    return nil unless params[:id]
    @contract
  end

  def current_module
    unless @service.nil?
      'dashboard'
    else
      'contract'
    end
  end

  def current_authorized_resource
    current_service
  end

  def authorize_contract_action
    unless current_contract.nil?
      unless @contract.can?(current_user, action_name.to_sym)
        flash[:error] = I18n.t('misc.not_authorized')
        return (@contract.can?(current_user, :show) ? redirect_to_show : redirect_to_index)
      end
    end
  end

end