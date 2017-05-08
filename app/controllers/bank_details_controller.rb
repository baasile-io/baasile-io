class BankDetailsController < ApplicationController

  before_action :load_service
  before_action :load_contract

  # # # # dashboard

  # Authorization
  before_action :authenticate_user!
  before_action :authorize_action

  # # # #

  before_action :load_entreprise_owner
  before_action :load_bank_detail, only: [:edit, :show, :update, :destroy]

  def index
    @collection = BankDetail.by_service(current_entreprise_owner)
  end

  def new
    @bank_detail = BankDetail.new
    @form_values = get_form_values
  end

  def create
    @bank_detail = BankDetail.new
    @bank_detail.user = current_user
    @bank_detail.service = current_entreprise_owner
    @bank_detail.contract = nil
    @bank_detail.assign_attributes(bank_detail_params)
    if @bank_detail.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.bank_detail'))
      set_service_to_redirect
      redirect_to_show
    else
      params[:from_contract] = params[:bank_detail][:from_contract]
      params[:entreprise_owner_id] = params[:bank_detail][:entreprise_owner_id]
      params[:from_service] = params[:bank_detail][:from_service]
      @contract = nil
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
    @bank_detail.assign_attributes(bank_detail_params)
    if @bank_detail.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bank_detail'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :edit
    end
  end

  def destroy
    if @bank_detail.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.bank_detail'))
      redirect_to_index
    else
      flash[:error] = I18n.t('errors.an_error_occured',resource: t('activerecord.models.bank_detail') )
      render :show
    end
  end

  private

  def get_form_values
    return [current_entreprise_owner, current_bank_detail] if @contract.nil?
    return [@service, @contract, current_bank_detail] unless @service.nil?
    return [@contract, current_bank_detail]
  end

  def redirect_to_index
    return redirect_to service_bank_details_path(current_entreprise_owner) if @contract.nil?
    unless @service.nil?
      return redirect_to client_bank_details_service_contract_path(@service, @contract) if current_entreprise_owner.id == @contract.client.id
      return redirect_to startup_bank_details_service_contract_path(@service, @contract) if current_entreprise_owner.id == @contract.proxy.service.id
    end
    return redirect_to client_bank_details_contract_path(@contract) if current_entreprise_owner == @contract.client
    return redirect_to startup_bank_details_contract_path(@contract) if current_entreprise_owner == @contract.proxy.service
  end

  def redirect_to_show
    return redirect_to service_bank_detail_path(current_entreprise_owner, current_bank_detail) if @contract.nil?
    unless @service.nil?
      return redirect_to client_bank_details_service_contract_path(@service, @contract) if current_entreprise_owner.id == @contract.client.id
      return redirect_to startup_bank_details_service_contract_path(@service, @contract) if current_entreprise_owner.id == @contract.proxy.service.id
    end
    return redirect_to client_bank_details_contract_path(@contract) if current_entreprise_owner.id == @contract.client.id
    return redirect_to startup_bank_details_contract_path(@contract) if current_entreprise_owner.id == @contract.proxy.service.id
  end

  def set_service_to_redirect
    if !@contract.nil? && params.key?(:bank_detail) && !params[:bank_detail][:from_service].blank?
      @service = Service.find(params[:bank_detail][:from_service])
    end
  end

  def load_service
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    end
  end

  def load_contract
    if params.key?(:contract_id)
      @contract = Contract.find(params[:contract_id])
    elsif params.key?(:bank_detail) && !params[:bank_detail][:from_contract].blank?
      @contract = Contract.find(params[:bank_detail][:from_contract])
    end
  end

  def load_entreprise_owner
    if !@contract.nil? && params.key?(:entreprise_owner_id)
      @entreprise_owner = Service.find(params[:entreprise_owner_id])
    elsif bank_detail_params.key?(:entreprise_owner_id)
      @entreprise_owner = Service.find(bank_detail_params[:entreprise_owner_id])
    else
      @entreprise_owner = @service
    end
  end

  def load_bank_detail
    @bank_detail = BankDetail.find(params[:id])
  end

  def current_service
    @service
  end

  def current_entreprise_owner
    @entreprise_owner
  end

  def current_contract
    @contract
  end

  def current_bank_detail
    @bank_detail
  end

  def bank_detail_params
    allowed_parameters = [:name, :bank_name, :account_owner, :bic, :iban]
    if params.key?(:bank_detail)
      return params.require(:bank_detail).permit(allowed_parameters)
    end
    return Hash.new
  end

  def current_module
    unless current_service.nil?
    'dashboard'
    end
  end

  def current_authorized_resource
    current_entreprise_owner
  end

end
