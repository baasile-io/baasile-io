class BankingDetailsController < DashboardController
  before_action :load_banking_detail, only: [:edit, :show, :update, :destroy]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:index, :show]

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('banking_details.index.title'), :service_proxies_path
    add_breadcrumb current_banking_detail.name, service_banking_detail_path(current_service, current_banking_detail) if current_banking_detail
  end

  def index
    @collection = BankingDetail.by_service(current_service)
  end

  def new
    @banking_detail = BankingDetail.new
  end

  def create
    @banking_detail = BankingDetail.new
    @banking_detail.user = current_user
    @banking_detail.service = current_service
    @banking_detail.contract = nil
    @banking_detail.assign_attributes(banking_detail_params)
    if @banking_detail.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.banking_detail'))
      redirect_to_show
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @banking_detail.assign_attributes(banking_detail_params)
    if @banking_detail.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.banking_detail'))
      redirect_to_show
    else
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

  def redirect_to_index
    redirect_to service_banking_details_path(current_service)
  end

  def redirect_to_show
    redirect_to service_banking_detail_path(current_service, @banking_detail)
  end

  def load_banking_detail
    @banking_detail = BankingDetail.find(params[:id])
  end

  def current_banking_detail
    return nil unless params[:id]
    @banking_detail
  end

  def banking_detail_params
    allowed_parameters = [:name, :bank_name, :account_owner, :bic, :iban]
    params.require(:banking_detail).permit(allowed_parameters)
  end
end
