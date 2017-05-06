class BankingDetailsController < ApplicationController

  before_action :load_service
  before_action :load_contract

  # # # # dashboard

  # Authorization
  before_action :authenticate_user!
  before_action :authorize_action

  # # # #

  before_action :load_entreprise_owner
  before_action :load_banking_detail, only: [:edit, :show, :update, :destroy]

  def index
    @collection = BankingDetail.by_service(current_entreprise_owner)
  end

  def new
    @banking_detail = BankingDetail.new
    @form_values = get_form_values
  end

  def create
    @banking_detail = BankingDetail.new
    @banking_detail.user = current_user
    @banking_detail.service = current_entreprise_owner
    @banking_detail.contract = nil
    @banking_detail.assign_attributes(banking_detail_params)
    if @banking_detail.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.banking_detail'))
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
    @banking_detail.assign_attributes(banking_detail_params)
    if @banking_detail.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.banking_detail'))
      redirect_to_show
    else
      @form_values = get_form_values
      render :edit
    end
  end

  def destroy
    if @banking_detail.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.banking_detail'))
      redirect_to_index
    else
      flash[:error] = I18n.t('errors.an_error_occured',resource: t('activerecord.models.banking_detail') )
      render :show
    end
  end

  private

  def get_form_values
    return [current_entreprise_owner, current_banking_detail] if @contract.nil?
    return [@service, @contract, current_banking_detail] unless @service.nil?
    return [@contract, current_banking_detail]
  end

  def redirect_to_index
    return redirect_to service_banking_details_path(current_entreprise_owner) if @contract.nil?
    return redirect_to banking_details_service_contract_path(@service, @contract) unless @service.nil?
    return redirect_to client_banking_details_contract_path(@contract) if current_entreprise_owner == @contract.client
    return redirect_to startup_banking_details_contract_path(@contract) if current_entreprise_owner == @contract.proxy.service
  end

  def redirect_to_show
    return redirect_to service_banking_detail_path(current_entreprise_owner, current_banking_detail) if @contract.nil?
    return redirect_to service_contract_banking_details_path(@service, @contract) unless @service.nil?
    return redirect_to client_banking_details_contract_path(@contract) if current_entreprise_owner.id == @contract.client.id
    return redirect_to startup_banking_details_contract_path(@contract) if current_entreprise_owner.id == @contract.proxy.service.id
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

  def load_entreprise_owner
    if !@contract.nil? && params.key?(:entreprise_owner_id)
      @entreprise_owner = Service.find(params[:entreprise_owner_id])
    elsif banking_detail_params.key?(:entreprise_owner_id)
      @entreprise_owner = Service.find(banking_detail_params[:entreprise_owner_id])
    else
      @entreprise_owner = @service
    end
  end

  def load_banking_detail
    @banking_detail = BankingDetail.find(params[:id])
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

  def current_banking_detail
    @banking_detail
  end

  def banking_detail_params
    allowed_parameters = [:name, :bank_name, :entreprise_owner_id, :account_owner, :bic, :iban]
    if params.key?(:banking_detail)
      return params.require(:banking_detail).permit(allowed_parameters)
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
