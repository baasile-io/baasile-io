class RoutesController < DashboardController
  before_action :load_route, only: [:show, :edit, :update, :destroy]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:index, :show]

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy)
    add_breadcrumb I18n.t('routes.index.title'), :service_proxy_routes_path
    add_breadcrumb current_route.name, service_proxy_route_path(current_service, current_proxy, current_route) if current_route
  end

  def index
    @collection = current_proxy.routes.authorized(current_user)
    if @collection.size == 0
      redirect_to new_service_proxy_route_path
    end
  end

  def new
    @route = Route.new
  end

  def create
    @route = Route.new
    @route.user = current_user
    @route.proxy = current_proxy
    @route.assign_attributes(route_params)

    if @route.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.route'))
      redirect_to service_proxy_route_path(current_service, @route.proxy, @route)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @route.assign_attributes(route_params)
    if @route.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.route'))
      redirect_to service_proxy_route_path(current_service, @route.proxy, @route)
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    if @route.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.route'))
      redirect_to service_proxy_routes_path(current_service, current_proxy)
    else
      flash[:error] = @route.errors.full_messages.join(', ')
      render :show
    end
  end

  def route_params
    params.require(:route).permit(:name, :subdomain, :description, :url, :protocol, :hostname, :port, :protocol_test, :hostname_test, :port_test, :measure_token_activated, allowed_methods: [])
  end

  def load_route
    @route = Route.find_by_id(params[:id])
    return redirect_to services_path if @route.nil?
  end

  def current_proxy
    @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
  end

  def current_route
    return nil unless params[:id]
    @route if @route.persisted?
  end
end
