class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_service
  helper_method :current_proxy
  helper_method :current_route

  def current_service
    nil
  end

  def current_proxy
    nil
  end

  def current_route
    nil
  end

  def switch_service
    s = Service.find_by_subdomain(params[:service_subdomain])
    unless s.nil?
      session[:service_subdomain] = params[:service_subdomain]
      current_user.update current_subdomain: params[:service_subdomain]
      if params.key?("service_owner_id")
        return service_admin_redirect(s)
      else
        return redirect_to back_office_dashboards_path
      end
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def service_admin_redirect(s)
    redirect_back(fallback_location: root_path) unless is_super_admin
    service_owner = Service.find(params[:service_owner_id])
    service_owner.add_role(:permissions, s)
    return redirect_to back_office_permission_list_proxies_routes_path(params[:service_owner_id])
  end

    def is_super_admin
      return current_user.has_role?(:superadmin)
    end
end
