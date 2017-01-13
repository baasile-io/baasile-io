module BackOffice
  class PermissionsController < BackOfficeController

    before_action :authorize_superadmin
    before_action :get_service_owner,
                  only: [:list_proxies_routes, :set_right_proxy,
                         :unset_right_proxy, :set_right_route,
                         :unset_right_route]

    def list_services
      @collection = Service.all
    end

    def list_proxies_routes
      @collection_proxies = Proxy.all
    end

    def set_right_proxy
      proxy_targeted = Proxy.find_by_id(params[:id])
      @service_owner.add_role :all, proxy_targeted
      redirect_to back_office_permissions_list_proxies_routes_path(service_id: params[:service_id])
    end

    def unset_right_proxy
      proxy_targeted = Proxy.find_by_id(params[:id])
      @service_owner.remove_role :all, proxy_targeted
      redirect_to back_office_permissions_list_proxies_routes_path(service_id: params[:service_id])
    end

    def set_right_route
      route_targeted = Route.find_by_id(params[:id])
      @service_owner.add_role(:all, route_targeted)
      redirect_to back_office_permissions_list_proxies_routes_path(service_id: params[:service_id])
    end

    def unset_right_route
      route_targeted = Route.find_by_id(params[:id])
      @service_owner.remove_role :all, route_targeted
      redirect_to back_office_permissions_list_proxies_routes_path(service_id: params[:service_id])
    end

    def get_service_owner
      @service_owner = Service.find_by_id(params[:service_id])
      return head(:forbidden) if @service_owner.nil?
    end

    def authorize_superadmin
      return head(:forbidden) unless is_super_admin
    end

  end
end