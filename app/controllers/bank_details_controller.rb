class BankDetailsController < ApplicationController

  before_action :load_service
  before_action :load_contract

  # # # # dashboard

  # Authorization
  before_action :authenticate_user!
  before_action :authorize_action

  # # # #

  before_action :load_service_owner
  before_action :load_bank_detail, only: [:edit, :show, :update, :destroy]

  def index
    @collection = BankDetail.by_service(current_service_owner)
  end

  def new
    @current_bank_detail = BankDetail.new
    @form_values = get_form_values
  end

  def create
    @current_bank_detail = BankDetail.new
    @current_bank_detail.user = current_user
    @current_bank_detail.service = current_service_owner
    @current_bank_detail.contract = nil
    @current_bank_detail.assign_attributes(bank_detail_params)
    if @current_bank_detail.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.bank_detail'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :new
    end
  end

  def show
  end

  def edit
    @form_values = get_form_values
  end

  def update
    @current_bank_detail.assign_attributes(bank_detail_params)
    if @current_bank_detail.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bank_detail'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :edit
    end
  end

  def destroy
    if @current_bank_detail.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.bank_detail'))
      redirect_to_index
    else
      flash[:error] = I18n.t('errors.an_error_occured',resource: t('activerecord.models.bank_detail') )
      render :show
    end
  end

  private

  def get_form_values
    return [current_service_owner, current_bank_detail] #if current_contract.nil?
    #return [current_service, current_contract, current_bank_detail] unless current_service.nil?
    #return [current_contract, current_bank_detail]
  end

  def redirect_to_index
    return redirect_to service_bank_details_path(current_service_owner) #if current_contract.nil?
    #unless current_service.nil?
    #  return redirect_to client_bank_details_service_contract_path(current_service, current_contract) if current_service_owner.id == current_contract.client.id
    #  return redirect_to startup_bank_details_service_contract_path(current_service, current_contract) if current_service_owner.id == current_contract.proxy.service.id
    #end
    #return redirect_to client_bank_details_contract_path(current_contract) if current_service_owner == current_contract.client
    #return redirect_to startup_bank_details_contract_path(current_contract) if current_service_owner == current_contract.proxy.service
  end

  def redirect_to_show
    return redirect_to service_bank_detail_path(current_service_owner, current_bank_detail) #if current_contract.nil?
    #unless @service.nil?
    #  return redirect_to client_bank_details_service_contract_path(current_service, current_contract) if current_service_owner.id == current_contract.client.id
    #  return redirect_to startup_bank_details_service_contract_path(current_service, current_contract) if current_service_owner.id == current_contract.proxy.service.id
    #end
    #return redirect_to client_bank_details_contract_path(current_contract) if current_service_owner.id == current_contract.client.id
    #return redirect_to startup_bank_details_contract_path(current_contract) if current_service_owner.id == current_contract.proxy.service.id
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

  def load_service_owner
    #if !@contract.nil? && params.key?(:service_owner_id)
    #  @service_owner = Service.find(params[:service_owner_id])
    #else
      @service_owner = @service
    #end
  end

  def load_bank_detail
    @current_bank_detail = BankDetail.find(params[:id])
  end

  def current_service
    @service
  end

  def current_service_owner
    @service_owner
  end

  def current_contract
    @contract
  end

  def current_bank_detail
    @current_bank_detail
  end

  def bank_detail_params
    allowed_parameters = [:name, :bank_name, :account_owner, :bic, :iban]
    return params.require(:bank_detail).permit(allowed_parameters)
  end

  def current_module
    unless current_service.nil?
    'dashboard'
    end
  end

  def current_authorized_resource
    current_service_owner
  end

end
