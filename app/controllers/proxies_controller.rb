class ProxiesController < DashboardController
  before_action :load_proxy_and_authorize, only: [:show, :edit, :update, :destroy]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:index, :show]

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy) if current_proxy
  end

  def index
    @collection = current_service.proxies.authorized(current_user)
  end

  def new
    @proxy = Proxy.new
    @proxy.build_proxy_parameter
  end

  def create
    @proxy = Proxy.new(proxy_params)
    @proxy.user = current_user
    @proxy.service = current_service
    @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.authorization_required? && @proxy.proxy_parameter.identifier.nil?

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
    @proxy.assign_attributes(proxy_params)
    if @proxy.proxy_parameter.authorization_required?
      @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
    else
      @proxy.proxy_parameter.identifier.destroy unless @proxy.proxy_parameter.identifier.nil?
    end
    if @proxy.save
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
    params.require(:proxy).permit(:name, :description, :alias, proxy_parameter_attributes: [:id, :follow_url, :follow_redirection, :authorization_mode, :protocol, :hostname, :port, :authorization_url, :realm, :grant_type, scopes: [], identifier_attributes: [:id, :client_id, :client_secret]])
  end

  def load_proxy_and_authorize
    @proxy = Proxy.includes(:proxy_parameter, {:proxy_parameter => :identifier}).find_by_id(params[:id])
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
