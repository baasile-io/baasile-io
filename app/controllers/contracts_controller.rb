class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize
  before_action :load_contract, only: [:show, :audit, :edit, :update, :destroy, :validate, :reject, :general_condition, :validate_general_condition, :comments, :prices, :select_price, :client_bank_details, :select_startup_bank_detail, :select_client_bank_detail, :client_bank_details_selection, :startup_bank_details, :startup_bank_details_selection, :cancel, :print_current_month_consumption, :error_measurements, :error_measurement, :reset_free_count_limit]
  before_action :load_general_condition, only: [:general_condition]

  # Authorization
  before_action :authorize_action
  before_action :authorize_contract_action

  # banking details init
  before_action :init_client_and_bank_detail, only: [:client_bank_details, :client_bank_details_selection]
  before_action :init_startup_and_bank_detail, only: [:startup_bank_details, :startup_bank_details_selection]

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
    load_active_proxies
    @logotype_service = LogotypeService.new
  end

  def new
    return redirect_to (current_service.nil? ? select_client_contracts_path : select_client_service_contracts_path(current_service)) if current_service.nil? || current_service.is_company?
    return redirect_to (current_service.nil? ? catalog_contracts_path : catalog_service_contracts_path(current_service)) unless params[:proxy_id].present?

    existing_contract = current_service.contracts_as_client.where(proxy_id: params[:proxy_id]).first
    if existing_contract
      flash[:success] = I18n.t('misc.existing_contract')
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

      unless params[:new_comment].blank?
        comment = ::Services::Comments::Create.new({body: params[:new_comment]},
                                                   commentable: @contract,
                                                   user: current_user).call
      end

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
    begin
      if current_contract.status.to_sym == :validation_production
        @current_month_consumption = Bills::BillingService.new(current_contract, Date.today).prepare
      end
    rescue
    end
  end

  def print_current_month_consumption
    billing_service = Bills::BillingService.new(current_contract, Date.today)
    billing_service.prepare
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

      # send email notifications
      users_to_notify = Contract::CONTRACT_STATUSES[old_status_key][:notifications].each_with_object([]) do |(service_type, user_roles), users|
        user_roles.each do |user_role|
          users.push(@contract.send(service_type).send("main_#{user_role}"))
        end
      end.reject(&:blank?).uniq
      users_to_notify.each do |user|
        ContractNotifier.send_validated_status_notification(@contract, user, from_status: old_status_key).deliver_now
      end

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

      # send email notifications
      users_to_notify = Contract::CONTRACT_STATUSES[old_status_key][:notifications].each_with_object([]) do |(service_type, user_roles), users|
        user_roles.each do |user_role|
          users.push(@contract.send(service_type).send("main_#{user_role}"))
        end
      end.reject(&:blank?).uniq
      users_to_notify.each do |user|
        ContractNotifier.send_rejected_status_notification(@contract, user, from_status: old_status_key).deliver_now
      end

      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      unless @contract.can?(current_user, :show)
        return redirect_to_index
      end
    else
      flash[:error] = @contract.errors.full_messages.join(', ')
    end
    redirect_to_show
  end

  def prices
    @price_templates = Price.templates(@contract.proxy)
  end

  # # banking details actions

  def client_bank_details
    return client_bank_details_selection if @contract.client_bank_detail.nil?
    render :bank_details
  end

  def startup_bank_details
    return startup_bank_details_selection if @contract.startup_bank_detail.nil?
    render :bank_details
  end

  def client_bank_details_selection
    @bank_detail_templates = @contract.client.bank_details.activated
    render :bank_details_selection
  end

  def startup_bank_details_selection
    @bank_detail_templates = @contract.startup.bank_details.activated
    render :bank_details_selection
  end

  def select_client_bank_detail
    @contract.client_bank_detail = @contract.client.bank_details.find(params[:bank_detail_id])
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    else
      flash[:error] = ([I18n.t('errors.an_error_occured')] + @contract.errors.full_messages).join(', ')
      return redirect_to polymorphic_path([current_service, current_contract], action: 'client_bank_details_selection')
    end
    redirect_to_show
  end

  def select_startup_bank_detail
    @contract.startup_bank_detail = @contract.startup.bank_details.find(params[:bank_detail_id])
    if @contract.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
    else
      flash[:error] = ([I18n.t('errors.an_error_occured')] + @contract.errors.full_messages).join(', ')
      return redirect_to polymorphic_path([current_service, current_contract], action: 'startup_bank_details_selection')
    end
    redirect_to_show
  end

  # # # #

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

    redirect_to polymorphic_path([current_service, @contract], action: :prices)
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
    @collection = @contract.error_measurements.includes(:client, :proxy).order(created_at: :desc)

    @collection = paginate @collection
  end
  
  def error_measurement
    @error_measurement = current_contract.error_measurements.includes(:proxy, :client).find(params[:id_error_measurement])
    render 'error_measurements/show'
  end

  def reset_free_count_limit
    if @contract.status.to_sym == :validation
      if Contracts::ContractResetFreeCountLimit.new(@contract).call
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
      else
        flash[:error] = I18n.t('errors.an_error_occured')
      end
    end
    redirect_to_show
  end

  private

  # # banking details functions

  def init_client_and_bank_detail
    @service_owner = @contract.client
    @bank_detail = @contract.client_bank_detail
  end

  def init_startup_and_bank_detail
    @service_owner = @contract.startup
    @bank_detail = @contract.startup_bank_detail
  end

  # # # #

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
    @contract = Contract.includes(:client_bank_detail, :startup_bank_detail, :price, :client, :startup, :proxy).find(params[:id])
    @current_status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
  end

  def load_active_proxies
    startups_scope = Service.activated_startups.published.order(name: :asc)
    @startups = startups_scope

    if params[:startup_id].present?
      startups_scope = startups_scope.where(id: params[:startup_id])
    end

    @proxies = []
    startups_scope.includes(:proxies).each do |service|
      @proxies += service.proxies.includes(:category).published.to_a
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

  def contract_params_bank_detail
    allowed_parameters = [:bank_detail_id]
    params.require(:contract).permit(allowed_parameters)
  end

  def contract_params_price
    allowed_parameters = [:price_id]
    params.require(:contract).permit(allowed_parameters)
  end

  def contract_params(status)
    allowed_parameters = Contract::CONTRACT_STATUSES[status.to_sym][:allowed_parameters].each_with_object([]) do |(scope, attributes), tmp_allowed_parameters|
      tmp_allowed_parameters.concat(attributes)
    end
    allowed_parameters.reject! {|attribute| !current_contract.can_edit_attribute?(current_user, attribute)} if current_contract
    params.require(:contract).permit(allowed_parameters)
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
