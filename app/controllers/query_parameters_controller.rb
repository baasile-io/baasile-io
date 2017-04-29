class QueryParametersController < DashboardController
  before_action :load_query_parameter, only: [:edit, :update, :destroy]
  before_action :load_query_parameters, only: [:index, :create]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:index]

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy)
    add_breadcrumb I18n.t('routes.index.title'), :service_proxy_routes_path
    add_breadcrumb current_route.name, service_proxy_route_path(current_service, current_proxy, current_route)
    add_breadcrumb I18n.t('query_parameters.index.title'), :service_proxy_route_query_parameters_path
  end

  def new
    @query_parameter = QueryParameter.new(mode: QueryParameter::MODES[:optional])
  end

  def create
    @query_parameter = QueryParameter.new
    @query_parameter.user = current_user
    @query_parameter.route = current_route
    @query_parameter.assign_attributes(query_parameter_params)

    if @query_parameter.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.query_parameter'))
      redirect_to_index
    else
      render :index
    end
  end

  def update
    @query_parameter.assign_attributes(query_parameter_params)
    if @query_parameter.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.query_parameter'))
      redirect_to_index
      else
      render :edit
    end
  end

  def edit
  end

  def destroy
    if @query_parameter.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.query_parameter'))
    end
    redirect_to_index
  end

  def index
    @query_parameter = QueryParameter.new(mode: QueryParameter::MODES[:optional])
  end

  private

  def redirect_to_index
    redirect_to service_proxy_route_query_parameters_path(current_service, @query_parameter.route.proxy, @query_parameter.route)
  end

  def query_parameter_params
    params.require(:query_parameter).permit(:name, :description, :mode, :query_parameter_type, :default_value)
  end

  def load_query_parameter
    @query_parameter = QueryParameter.find_by_id(params[:id])
    return redirect_to services_path if @query_parameter.nil?
  end

  def current_route
    @current_route ||= Route.find_by_id(params[:route_id])
  end

  def current_proxy
    @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
  end

  def load_query_parameters
    @collection = current_route.query_parameters
  end
end
