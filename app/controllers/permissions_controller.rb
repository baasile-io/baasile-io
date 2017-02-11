class PermissionsController < DashboardController
  before_action :authorize_superadmin
  before_action :get_service_owner,
                only: [:list_services, :list_proxies_routes, :set_right_proxy,
                       :unset_right_proxy, :set_right_route,
                       :unset_right_route, :set_right, :unset_right]

  def list_services
    @collection = Service.where.not(id: @service_owner.id)
  end

  def list_proxies_routes
    @collection_proxies = Proxy.all
  end

  def set_right
    service_targeted = Service.find(params[:id])
    @service_owner.add_role(:all, service_targeted)
    redirect_to service_permissions_list_services_path(@service_owner.id)
  end

  def unset_right
    service_targeted = Service.find(params[:id])
    @service_owner.remove_role :all, service_targeted
    redirect_to service_permissions_list_services_path(@service_owner.id)
  end

  def set_right_proxy
    proxy_targeted = Proxy.find_by_id(params[:id])
    @service_owner.add_role :all, proxy_targeted
    redirect_to service_permissions_list_proxies_routes_path(current_service, service_id: params[:service_id])
  end

  def unset_right_proxy
    proxy_targeted = Proxy.find_by_id(params[:id])
    @service_owner.remove_role :all, proxy_targeted
    redirect_to service_permissions_list_proxies_routes_path(current_service, service_id: params[:service_id])
  end

  def set_right_route
    route_targeted = Route.find_by_id(params[:id])
    @service_owner.add_role(:all, route_targeted)
    redirect_to service_permissions_list_proxies_routes_path(current_service, service_id: params[:service_id])
  end

  def unset_right_route
    route_targeted = Route.find_by_id(params[:id])
    @service_owner.remove_role :all, route_targeted
    redirect_to service_permissions_list_proxies_routes_path(current_service, service_id: params[:service_id])
  end

  def get_service_owner
    @service_owner = Service.find_by_id(params[:service_id])
    return head(:forbidden) if @service_owner.nil?
  end

  def authorize_superadmin
    return head(:forbidden) unless current_user.is_superadmin?
  end

  def is_admin_of(service)
    return @service_owner.has_role? :all, service
  end

  helper_method :is_admin_of
end
