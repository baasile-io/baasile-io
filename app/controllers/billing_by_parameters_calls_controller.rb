class BillingByParametersCalls < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_service_and_authorize!
  before_action :load_billing_and_authorize
  before_action :load_billing_by_parameters_call, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb current_billing.name, service_billing_path(current_service, current_billing)
  end

  def index
    @collection = Billing_by_parameters_call.where(billing: @billing)
  end

  def new
    @billing_by_parameters_call = Billing_by_parameters_call.new
  end

  def create
    @billing_by_parameters_call = Billing_by_parameters_call.new
    @billing_by_parameters_call.user = current_user
    @billing_by_parameters_call.billing = current_billing
    @billing_by_parameters_call.assign_attributes(billing_by_parameters_call_params)
    if @billing_by_parameters_call.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.billing_by_parameters_call'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
  end

  def update
    @billing_by_parameters_call.assign_attributes(billing_by_parameters_call_params)
    if @billing_by_parameters_call.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.billing_by_parameters_call'))
      redirect_to_show
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @billing_by_parameters_call.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.billing_by_parameters_call'))
      redirect_to_index
    else
      render :show
    end
  end

  def toogle_activate
    @billing_by_parameters_call.activate = !@billing_by_parameters_call.activate
    @billing_by_parameters_call.save
    redirect_to_show
  end

  private

  def redirect_to_index
    return redirect_to service_billing_by_parameters_calls_path(current_service)
  end

  def redirect_to_show
    return redirect_to service_billing_by_parameters_call_path(current_service, @billing)
  end

  def load_billing_by_parameters_call
    @billing_by_parameters_call = Billing_by_parameters_call.find(params[:id])
  end

  def load_billing_and_authorize
    if params.key?(:billing_id)
      @billing = Billing.find(params[:billing_id])
    else
      return head(:forbidden)
    end
  end

  def load_service_and_authorize!
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    else
      return head(:forbidden)
    end
  end

  def billing_by_parameters_call_params
    allowed_parameters = [:name]
    params.require(:billing_by_parameters_call).permit(allowed_parameters)
  end

  def is_commercial?
    current_user.is_commercial?
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

  def current_billing
    return nil unless params[:billing_id]
    @billing
  end

  def current_module
      'dashboard'
  end
end