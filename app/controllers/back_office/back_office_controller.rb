module BackOffice
  class BackOfficeController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_schema
    before_action :authorize_user

    def authenticate_schema
      if current_service.nil? || !current_service.is_activated? || current_service.subdomain != current_user.current_subdomain
        redirect_to root_path
        return false
      end
      Apartment::Tenant.switch session[:service_subdomain]
    end

    def current_service
      @current_service ||= Service.find_by_subdomain(session[:service_subdomain])
    end

    def authorize_user
      return head(:forbidden) unless current_user.has_role?(:superadmin) || current_user.has_role?(:developer, current_service)
    end
  end
end
