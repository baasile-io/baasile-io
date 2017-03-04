class BillingsController < ApplicationController
  before_action :authenticate_user!
  before_action :is_commercial?
  before_action :load_service_and_authorize!
  before_action :load_billing, only: [:show, :edit, :update, :destroy]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
  end

  def index
    @collection = Billing.where(service: current_service)
  end

  def new
    @billing = Billing.new
  end

  def create
    @billing = Billing.new
    @billing.user = current_user
    @billing.service = current_service
    @billing.assign_attributes(billing_params)
    if @billing.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.billing'))
      redirect_to_show
    else
      render :new
    end
  end

  def edit
  end

  def update
    @billing.assign_attributes(billing_params)
    if @billing.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.billing'))
      redirect_to_show
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @billing.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.billing'))
      redirect_to_index
    else
      render :show
    end
  end

  def toogle_activate
    @billing.activate = !@billing.activate
    @billing.save
    redirect_to_show
  end

  private

  def redirect_to_index
    return redirect_to service_billings_path(current_service)
  end

  def redirect_to_show
    return redirect_to service_billing_path(current_service, @billing)
  end

  def load_billing
    @billing = Billing.find(params[:id])
  end

  def load_service_and_authorize!
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
    else
      return head(:forbidden)
    end
  end

  def billing_params
    allowed_parameters = [:name, :base_cost, :free_hour, :cost_by_time]
    params.require(:billing).permit(allowed_parameters)
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

  def current_module
      'dashboard'
  end
end