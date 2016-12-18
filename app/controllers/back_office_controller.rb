class BackOfficeController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_tenant
  before_action :authorize_user

  def authenticate_tenant
    if Apartment::Tenant.current_tenant == 'public'
      redirect_to root_path
      return false
    end
    redirect_to root_path unless current_service.is_activated?
  end

  def current_service
    @current_service ||= Service.find_by_subdomain(Apartment::Tenant.current_tenant)
  end

  def authorize_user
    return head(:forbidden) unless current_user.has_role?(:superadmin) || current_user.has_role?(:developer, Service.find(Apartment::Tenant.current_tenant))
  end
end
