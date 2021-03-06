class RoutesController < DashboardController
  before_action :load_route, only: [:show, :audit, :edit, :update, :destroy, :confirm_destroy]

  # allow get measure info to show
  include ShowMeasurementConcern

  def index
    @collection = current_proxy.routes
  end

  def new
    @route = current_proxy.routes.build
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

  def confirm_destroy
  end

  def destroy
    if @route.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.route'))
      redirect_to service_proxy_routes_path(current_service, current_proxy)
    else
      flash[:error] = @route.errors.full_messages.join(', ')
      render :confirm_destroy
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
