module BackOffice
  class PermissionsController < BackOfficeController

    before_action :authorize_superadmin
    before_action :get_service_owner

    def index
      @collection = Array.new
      @collection_proxies = Proxy.all
      @collection_proxies.each do |proxy|
        @collection << { proxy: proxy, route: Route.find_by_id(proxy.id) }
      end
    end

    def list_proxies_route
      @collection = Array.new
      @collection_proxies = Proxy.all
      @collection_proxies.each do |proxy|
        @collection << { proxy: proxy, route: Route.find_by_id(proxy.id) }
      end
    end

    def set_right_for_proxy
      proxy_targeted = Proxy.find_by_id(params[:id])
      @service_owner.add_role :all, proxy_targeted
    end

    def unset_right_for_proxy
      proxy_targeted = Proxy.find_by_id(params[:id])
      @service_owner.remove_role :all, proxy_targeted
    end

    def set_right_for_route
      route_targeted = Route.find_by_id(params[:id])
      @service_owner.add_role(:all, route_targeted)
    end

    def unset_right_for_route
      route_targeted = Service.find(params[:target_id])
      service_owner.remove_role :all, route_targeted
    end

    def get_service_owner
      @service_owner = Service.find_by_id(params[:service_id])
      return head(:forbidden) if @service.nil?
    end

    def authorize_superadmin
      return head(:forbidden) unless is_super_admin
    end

  end
end