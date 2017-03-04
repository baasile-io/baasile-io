class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_company
  before_action :load_service
  before_action :load_contract, only: [:show, :edit, :update, :destroy, :commercial_validation, :commercial_reject, :toogle_activate]
  before_action :load_active_services, only: [:new, :edit, :create, :update]
  before_action :load_active_companies, only: [:new, :edit, :create, :update]
  before_action :load_active_client, only: [:new, :edit, :create, :update]

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
    @contract.company = current_company if !current_company.nil?
    @contract.client = current_service if !current_service.nil? && current_service.is_client?
    @contract.startup = current_service if !current_service.nil? && !current_service.is_client?
  end

  def create
    @contract = Contract.new
    @contract.user = current_user
    @contract.assign_attributes(contract_params)
    @contract.status = 1
    if @contract.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @contract.status >= 2
      @contract.status -= 1
    end
    @contract.assign_attributes(contract_params)
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
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
    if Contract.statuses[@contract.status] %2 == 1 && Contract.statuses[@contract.status] < 4
      if @contract.is_commercial?(current_user, :client)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status]]
      end
    elsif Contract.statuses[@contract.status] < 4
      if @contract.is_commercial?(current_user, :startup)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status]]
      end
    elsif Contract.statuses[@contract.status] %2 == 1 && Contract.statuses[@contract.status] >= 4
      if @contract.is_accounting?(current_user, :client)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status]]
      end
    elsif Contract.statuses[@contract.status] >= 4
      if @contract.is_accounting?(current_user, :startup)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status]]
      end
    end
    @contract.save
    redirect_to_show
  end

  def commercial_reject
    if Contract.statuses[@contract.status] %2 == 1 && Contract.statuses[@contract.status] < 4
      if @contract.is_commercial?(current_user, :client)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status] - 2]
      end
    elsif Contract.statuses[@contract.status] < 4
      if @contract.is_commercial?(current_user, :startup)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status] - 2]
      end
    elsif Contract.statuses[@contract.status] %2 == 1 && Contract.statuses[@contract.status] >= 4
      if @contract.is_accounting?(current_user, :client)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status] - 2]
      end
    elsif Contract.statuses[@contract.status] >= 4
      if @contract.is_accounting?(current_user, :startup)
        @contract.status = Contract.statuses.keys[Contract.statuses[@contract.status] - 2]
      end
    end
    @contract.save
    redirect_to_show
  end

  def toogle_activate
    @contract.activate = !@contract.activate
    @contract.save
    redirect_to_show
  end

  private

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

  def load_active_services
    @services = Service.activated_startups()
  end

  def load_active_client
    @clients = Service.activated_clients()
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

  def contract_params
    allowed_parameters = [:name, :start_date, :company_id, :startup_id, :client_id]
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