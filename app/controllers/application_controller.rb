class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_service

  def current_service
    nil
  end
end
