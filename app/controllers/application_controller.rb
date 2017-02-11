class ApplicationController < ActionController::Base
  # reset captcha code after each request for security
  after_action :reset_last_captcha_code!

  protect_from_forgery with: :exception

  helper_method :current_company
  helper_method :current_service
  helper_method :current_proxy
  helper_method :current_route
  helper_method :current_module

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || profile_path
  end

  def authenticate_user!(opts={})
    super(opts)
    unless current_user.is_active
      return head(:forbidden)
    end
  end

  def authorize_admin!
    unless current_user.is_admin_of?(current_company) || current_user.is_superadmin?
      return head(:forbidden)
    end
  end

  def current_company
    nil
  end

  def current_service
    nil
  end

  def current_proxy
    nil
  end

  def current_route
    nil
  end

  def current_module
    nil
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end
end
