class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
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
    @services = Service.activated_startup()
  end

  def load_active_client
    @clients = Service.activated_client()
  end

  def load_active_companies
    @companies = Company.all
  end

  def contract_params
    allowed_parameters = [:name, :start_date, :company_id, :startup_id, :client_id]
    params.require(:contract).permit(allowed_parameters)
  end

  def is_commercial?
    current_user.is_commercial?
  end

  def current_module
    'contract'
  end

end