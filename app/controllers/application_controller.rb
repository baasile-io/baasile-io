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
      return redirect_to back_office_dashboards_path
    end
    redirect_back(fallback_location: root_path)
  end
end
