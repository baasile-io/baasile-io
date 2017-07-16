class BackOfficeController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  layout 'back_office'

  def index
    @deactivated_services = Service.deactivated.order(updated_at: :desc)
  end

  def error_measurements

  end

  def authorize_superadmin!
    return head(:forbidden) unless current_user.is_superadmin?
  end

  def current_module
    'back_office'
  end
end