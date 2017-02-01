class ApplicationController < ActionController::Base
  # reset captcha code after each request for security
  after_action :reset_last_captcha_code!

  protect_from_forgery with: :exception

  helper_method :current_service
  helper_method :current_proxy
  helper_method :current_route

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


  private

    def is_super_admin
      return current_user.has_role?(:superadmin)
    end
end
