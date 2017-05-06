class BankingDetailsController < ApplicationController

  before_action :load_service
  before_action :load_contract

  # # # # dashboard

  # Authorization
  before_action :authenticate_user!
  before_action :authorize_action

  # # # #

  before_action :load_startup
  before_action :load_banking_detail, only: [:edit, :show, :update, :destroy]

  def index
    @collection = BankingDetail.by_service(@startup)
  end

  def new
    @banking_detail = BankingDetail.new
    @form_values = get_form_values
  end

  def create
    @banking_detail = BankingDetail.new
    @banking_detail.user = current_user
    @banking_detail.service = current_startup_owner
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
    return [@startup, current_banking_detail] if @contract.nil?
    return [@service, @contract, current_banking_detail] unless @service.nil?
    return [@contract,current_banking_detail]
  end

  def redirect_to_index
    return redirect_to service_banking_details_path(@startup) if @contract.nil?
    return redirect_to banking_details_service_contract_path(@service, @contract) unless @service.nil?
    return redirect_to banking_details_contract_path(@contract)
  end

  def redirect_to_show
    return redirect_to service_banking_detail_path(@startup, current_banking_detail) if @contract.nil?
    return redirect_to service_contract_banking_details_path(@service, @contract) unless @service.nil?
    return redirect_to contract_banking_details_path(@contract)
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

  def load_startup
    if @contract.nil?
      return @startup = @service
    end
    @startup = @contract.proxy.service
  end

  #def redirect_to_index
  #  redirect_to service_banking_details_path(current_service)
  #end

  #def redirect_to_show
  #  redirect_to service_banking_detail_path(current_service, @banking_detail)
  #end

  def load_banking_detail
    @banking_detail = BankingDetail.find(params[:id])
  end

  def current_service
    @service
  end

  def current_startup_owner
    @startup
  end

  def current_contract
    @contract
  end

  def current_banking_detail
    @banking_detail
  end

  def banking_detail_params
    allowed_parameters = [:name, :bank_name, :account_owner, :bic, :iban]
    params.require(:banking_detail).permit(allowed_parameters)
  end

  def current_module
    unless current_service.nil?
    'dashboard'
    end
  end

  def current_authorized_resource
    current_startup_owner
  end

end
