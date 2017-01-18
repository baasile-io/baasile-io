class RoutesController < DashboardController
  before_action :authorize_proxy
  before_action :load_route, only: [:show, :edit, :update, :destroy]

  def authorize_proxy
    return head(:forbidden) unless current_proxy.authorized?(current_user)
  end

  def index
    @collection = current_proxy.routes.authorized(current_user)
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
  end

  def route_params
    params.require(:route).permit(:name, :description, :url, :protocol, :hostname, :port, allowed_methods: [])
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
