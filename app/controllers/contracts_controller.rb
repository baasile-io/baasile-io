class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_company
  before_action :load_service
  before_action :load_contract, only: [:show, :edit, :update, :destroy, :commercial_validation, :commercial_reject, :toogle_activate, :toogle_production]
  before_action :load_contract_with_contract_id, only: [:set_price, :update_price]
  before_action :load_price, only: [:show]
  before_action :load_active_services, only: [:new, :edit, :create, :update]
  before_action :load_active_companies, only: [:new, :edit, :create, :update]
  before_action :load_active_client, only: [:new, :edit, :create, :update]
  before_action :load_price_associate_startup, only: [:set_price]
  before_action :load_active_proxies_and_authorize, only: [:new, :edit, :update, :create]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service) if current_service
  end

  def index
    if !current_company.nil?
      @collection = Contract.associated_companies(current_company)
    elsif !current_service.nil?
      @collection = Contract.associated_startups_clients(current_service)
    else
      @collection = Contract.all
    end
    @collection = @collection.reject { |contract| !contract.authorized_to_act?(current_user) }
  end

  def new
    @contract = Contract.new
    @contract.client = current_service if !current_service.nil? && current_service.is_client?
    @contract.startup = current_service if !current_service.nil? && current_service.is_startup?
    define_form_value
  end

  def create
    @contract = Contract.new
    @contract.user = current_user
    @contract.assign_attributes(contract_params)
    @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
    @contract.company = @contract.client.company unless @contract.client.company.nil?  unless @contract.client.nil?
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
    @contract.status = Contract.statuses[:creation]
    @contract.assign_attributes(contract_params)
    @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
    @contract.company = @contract.client.company unless @contract.client.company.nil? unless @contract.client.nil?
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

  def commercial_validation
    logger.info "@@@@@"
    if Contract::CONTRACT_STATUS[@contract.status.to_sym][:scope] == 'commercial'
      if @contract.is_commercial?(current_user, Contract::CONTRACT_STATUS[@contract.status.to_sym][:can_edit])
        logger.info @contract.status.inspect
        logger.info "#####"
        logger.info Contract::CONTRACT_STATUS[@contract.status.to_sym][:next].inspect
        logger.info "&&&&&"
        @contract.status = Contract::CONTRACT_STATUS[@contract.status.to_sym][:next] unless Contract::CONTRACT_STATUS[@contract.status.to_sym][:next].nil?
        logger.info @contract.status.inspect
        if @contract.save
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        end
      else
        flash[:success] = I18n.t('actions.back', resource: t('activerecord.models.contract'))
      end
    elsif Contract::CONTRACT_STATUS[@contract.status.to_sym][:scope] == 'accounting'
      if @contract.is_accounting?(current_user, Contract::CONTRACT_STATUS[@contract.status.to_sym][:can_edit])
        logger.info @contract.status.inspect
        logger.info "#####"
        @contract.status = Contract::CONTRACT_STATUS[@contract.status.to_sym][:next] unless Contract::CONTRACT_STATUS[@contract.status.to_sym][:next].nil?
        logger.info @contract.status.inspect
        if @contract.save
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        end
      else
        flash[:success] = I18n.t('actions.back', resource: t('activerecord.models.contract'))
      end
    end
    logger.info "@@@@@"
    redirect_to_show
  end

  def commercial_reject
    if Contract::CONTRACT_STATUS[@contract.status.to_sym][:scope] == 'commercial'
      if @contract.is_commercial?(current_user, Contract::CONTRACT_STATUS[@contract.status.to_sym][:can_edit])
        @contract.status = Contract::CONTRACT_STATUS[@contract.status.to_sym][:prev] unless Contract::CONTRACT_STATUS[@contract.status.to_sym][:prev].nil?
        if @contract.save
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        end
      end
    elsif Contract::CONTRACT_STATUS[@contract.status.to_sym][:scope] == 'accounting'
      if @contract.is_accounting?(current_user, Contract::CONTRACT_STATUS[@contract.status.to_sym][:can_edit])
        @contract.status = Contract::CONTRACT_STATUS[@contract.status.to_sym][:prev] unless Contract::CONTRACT_STATUS[@contract.status.to_sym][:prev].nil?
        if @contract.save
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        end
      end
    end
    redirect_to_show
  end

  def toogle_activate
    @contract.activate = !@contract.activate
    @contract.save
    redirect_to_show
  end

  def toogle_production
    @contract.production = !@contract.production
    @contract.save
    redirect_to_show
  end

  def set_price
    unless Contract.statuses[@contract.status] == Contract.statuses[:creation]
      redirect_to_show
    end
  end

  def update_price
    @contract.set_dup_price(contract_params_price[:price_id])
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
      render :set_price
    end
  end

  def define_form_value
    @form_values = get_for_values
  end

  private

  def get_for_values
    return [current_company, @contract] unless current_company.nil?
    return [current_service, @contract] unless current_service.nil?
    return [@contract]
  end

  def load_price
    unless @contract.price.nil?
      @price = @contract.price
      @price_parameters = PriceParameter.where(price: @price)
    end
  end

  def load_price_associate_startup
    @prices = Price.where(service_id: @contract.startup_id, attached: false)
  end

  def redirect_to_index
    return redirect_to company_contracts_path(current_company) unless current_company.nil?
    return redirect_to service_contracts_path(current_service) unless current_service.nil?
    return redirect_to contracts_path
  end

  def redirect_to_show
    return redirect_to company_contract_path(current_company, @contract) unless current_company.nil?
    return redirect_to service_contract_path(current_service, @contract) unless current_service.nil?
    return redirect_to contract_path(@contract)
  end

  def load_contract
    @contract = Contract.find(params[:id])
  end

  def load_contract_with_contract_id
    @contract = Contract.find(params[:contract_id])
  end

  def load_active_services
    @services = Service.activated_startups()
  end

  def load_active_client
    @clients = Service.activated_clients()
  end

  def load_active_proxies_and_authorize
    @proxies = []
    @services.each do |service|
      service.proxies.each do |proxy|
        @proxies << proxy
      end
    end
    if @proxies.count == 0
      redirect_to_index
    end
  end

  def load_active_companies
    @companies = Company.all
  end

  def load_company
    if params.key?(:company_id)
      @company = Company.find(params[:company_id])
    else
      @company = nil
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

  def contract_params
    allowed_parameters = [:code, :name, :start_date, :company_id, :proxy_id, :client_id]
    params.require(:contract).permit(allowed_parameters)
  end

  def is_commercial?
    current_user.is_commercial?
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_company
    return nil unless params[:company_id]
    @company
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

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