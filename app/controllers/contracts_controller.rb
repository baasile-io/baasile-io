class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :commercial?
  before_action :load_contract, only: [:show, :edit, :update, :destroy]
  before_action :load_active_services, only: [:new, :edit, :create, :update]
  before_action :load_active_companies, only: [:new, :edit, :create, :update]
  before_action :load_active_client, only: [:new, :edit, :create, :update]

  def index
    @collection = Contract.all
  end

  def new
    @contract = Contract.new
  end

  def create
    @contract = Contract.new
    @contract.user = current_user
    @contract.company_id = params[:contract][:company].to_i if params[:contract].key?(:company)
    @contract.startup_id = params[:contract][:startup].to_i if params[:contract].key?(:startup)
    @contract.client_id = params[:contract][:client].to_i if params[:contract].key?(:client)
    logger.info "#################@#@@"
    logger.info params.inspect
    logger.info "#################@#@@"

    @contract.assign_attributes(contract_params)
    if @contract.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.contract'))
      redirect_to contract_path(@contract)
    else
      render :new
    end
  end

  def edit

  end

  def update
    @contract.assign_attributes(contract_params)
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      redirect_to contract_path(@contract)
    else
      render :edit
    end
  end

  def show

  end

  def destroy
    if @contract.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.contract'))
      redirect_to contracts_path
    else
      render :show
    end
  end

  private

  def load_contract
    @contract = Contract.find(params[:id])
  end

  def load_active_services
    services = Service.activated_startup()
    @services = Hash.new()
    services.each do |service|
      @services[service.name] = service.id
    end
  end

  def load_active_client
    clients = Service.activated_client()
    @clients = Hash.new()
    clients.each do |client|
      @clients[client.name] = client.id
    end
  end

  def load_active_companies
    companies = Company.all
    @companies = Hash.new()
    companies.each do |company|
      @companies[company.name] = company.id
    end
  end

  def contract_params
    allowed_parameters = [:name, :start_date ]
    refactor_params()
    params.require(:contract).permit(allowed_parameters)
  end

  def refactor_params
  end

  def commercial?
    current_user.is_commercial?
  end

  def current_module
    'contract'
  end

end