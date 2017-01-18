class ProxiesController < DashboardController
  before_action :load_proxy_and_authorize, only: [:show, :edit, :update, :destroy]

  def index
    @collection = Proxy.authorized(current_user)
  end

  def new
    @proxy = Proxy.new
    @proxy.build_proxy_parameter
  end

  def create
    @proxy = Proxy.new(proxy_params)
    @proxy.user = current_user
    @proxy.service = current_service

    if @proxy.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.proxy'))
      redirect_to service_proxy_path(current_service, @proxy)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @proxy.update(proxy_params)
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.proxy'))
      redirect_to service_proxy_path(current_service, @proxy)
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @proxy.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.proxy'))
      redirect_to service_proxies_path(current_service)
    else
      render :show
    end
  end

  def proxy_params
    params.require(:proxy).permit(:name, :description, :alias, proxy_parameter_attributes: [:id, :follow_url, :follow_redirection, :authentication_mode, :protocol, :hostname, :port, :authentication_url, :realm, :grant_type, :client_id, :client_secret])
  end

  def load_proxy_and_authorize
    @proxy ||= Proxy.find_by_id(params[:id])
    return redirect_to services_path if @proxy.nil?
    unless @proxy.authorized?(current_user)
      return head(:forbidden)
    end
  end

  def current_proxy
    return nil unless params[:id]
    @proxy
  end
end
