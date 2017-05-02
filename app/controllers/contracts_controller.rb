class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize
  before_action :load_contract, only: [:show, :edit, :update, :destroy, :validate, :reject, :general_condition, :validate_general_condition, :comments, :prices, :select_price, :cancel, :print_current_month_consumption, :error_measurements]
  before_action :load_general_condition, only: [:general_condition]
  before_action :load_active_proxies, only: [:catalog]

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
      @collection = Contract.associated_services(current_service).order(status: :asc)
    else
      @collection = Contract.associated_users(current_user).order(status: :asc)
    end
  end

  def select_client
    @clients = (current_service.nil? ? current_user.services.clients_or_startups : current_service.children.clients_or_startups)
  end

  def catalog
    @logotype_service = LogotypeService.new
  end

  def new
    return redirect_to (current_service.nil? ? select_client_contracts_path : select_client_service_contracts_path(current_service)) if current_service.nil? || current_service.is_company?
    return redirect_to (current_service.nil? ? catalog_contracts_path : catalog_service_contracts_path(current_service)) unless params[:proxy_id].present?

    existing_contract = current_service.contracts.where(proxy_id: params[:proxy_id]).first
    if existing_contract
      return redirect_to (current_service.nil? ? contract_path(existing_contract) : service_contract_path(current_service, existing_contract))
    end

    @current_status = Contract::CONTRACT_STATUSES[:creation]
    @contract = Contract.new
    @contract.client = current_service if !current_service.nil?
    @contract.proxy = Proxy.find(params[:proxy_id])
    define_form_value
  end

  def create
    @current_status = Contract::CONTRACT_STATUSES[:creation]
    @contract = Contract.new
    @contract.general_condition = @general_condition
    @contract.user = current_user
    @contract.assign_attributes(contract_params(:creation))
    @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
    @contract.status = Contract.statuses[:creation]
    if @contract.save
      Comment.create(commentable: @contract, user: current_user, body: params[:new_comment]) unless params[:new_comment].blank?
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
      Comment.create(commentable: @contract, user: current_user, body: params[:new_comment]) unless params[:new_comment].blank?
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      redirect_to_show
    else
      define_form_value
      render :edit
    end
  end

  def show
    @logotype_service = LogotypeService.new
    #begin
      if current_contract.status.to_sym == :validation_production
        @current_month_consumption = Bills::BillingService.new(current_contract, Date.today).calculate
      end
    #rescue
    #  nil
    #end
  end

  def print_current_month_consumption
    billing_service = Bills::BillingService.new(current_contract, Date.today)
    billing_service.calculate
    pdf_path = Bills::GeneratePdfBillService.new(billing_service.bill).generate_pdf

    data = open(pdf_path)
    send_data data.read,
              disposition: 'attachment',
              filename: "abc.pdf",
              stream: 'true',
              buffer_size: '4096',
              type: 'application/pdf'
  end

  def destroy
    if @contract.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.contract'))
      redirect_to_index
    else
      render :show
    end
  end

  def validate_general_condition
    if @contract.general_condition_validated_client_user_id.nil?
      @contract.general_condition_validated_client_user = current_user
      @contract.general_condition_validated_client_datetime = DateTime.now
      if @contract.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      end
    else
      flash[:error] = I18n.t('misc.already_accepted')
    end
    redirect_to_show
  end

  def general_condition
  end

  def validate
    old_status_key = @contract.status.to_sym
    status = Contract::CONTRACT_STATUSES[old_status_key]
    @contract.status = status[:next] unless status[:next].nil?
    if @contract.save
      ContractNotifier.send_validated_status_notification(@contract, from_status: old_status_key).deliver_now
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    else
      flash[:error] = @contract.errors.full_messages.join(', ')
    end
    redirect_to_show
  end

  def reject
    old_status_key = @contract.status.to_sym
    status = Contract::CONTRACT_STATUSES[old_status_key]
    @contract.status = status[:prev] unless status[:prev].nil?
    if @contract.save
      ContractNotifier.send_rejected_status_notification(@contract, from_status: old_status_key).deliver_now
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      unless @contract.can?(current_user, :show)
        return redirect_to_index
      end
    else
      flash[:error] = @contract.errors.full_messages.join(', ')
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
      new_price = @contract.proxy.prices.find(price_id).dup
      new_price.save!
      @contract.price = new_price
    else
      @contract.create_price(user: current_user)
    end

    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    end

    return redirect_to edit_service_contract_price_path(current_service, @contract, @contract.price) unless current_service.nil?
    redirect_to edit_contract_price_path(@contract, @contract.price)
  end

  def define_form_value
    @form_values = get_for_values
    @new_comment = Comment.new(body: params[:new_comment])
  end

  def comments
    @comments = Comment.where(commentable: @contract).order(created_at: :desc)
    @comment = Comment.new(commentable: @contract)
  end

  def error_measurements

  end

  private

  def load_general_condition
    if @contract.nil? || @contract.general_condition.nil?
      @general_condition = GeneralCondition.effective_now
      @contract.general_condition = @general_condition unless @contract.nil?
    else
      @general_condition = @contract.general_condition
    end
    if @general_condition.nil?
      flash[:error] = I18n.t('errors.messages.missing_general_condition')
      return redirect_to_index
    end
  end

  def get_for_values
    return [current_service, @contract] unless current_service.nil?
    return [@contract]
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
    @contract = Contract.includes(:price, :client, :startup, :proxy).find(params[:id])
    @current_status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
  end

  def load_active_proxies
    @proxies = []
    Service.includes(:proxies).activated_startups.published.each do |service|
      @proxies += service.proxies.includes(:category).published.to_a
    end
    if @proxies.size == 0
      flash[:error] = I18n.t('misc.no_available_proxies')
      redirect_to_index
    end
  end

  def load_service_and_authorize
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
      unless @service.is_activated?
        flash[:error] = I18n.t('misc.service_not_activated')
        redirect_to service_path(current_service)
      end
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
