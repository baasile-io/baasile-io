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
end
