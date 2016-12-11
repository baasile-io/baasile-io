class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_tenant
  before_action :authorize_user

  def authenticate_tenant
    if Apartment::Tenant.current_tenant == 'public'
      redirect_to root_path
      return false
    end
  end

  def authorize_user
    return false unless current_user.has_role?(:superadmin) || current_user.has_role?(:developer, Service.find(Apartment::Tenant.current_tenant))
  end
end
