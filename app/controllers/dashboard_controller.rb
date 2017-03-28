class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_schema

  # Authorization
  before_action :authorize_action

  def authenticate_schema
    if current_service.nil?
      redirect_to root_path
      return false
    end
  end

  def current_service
    @current_service ||= Service.find(params[:service_id])
  end

  def current_module
    'dashboard'
  end

  def current_authorized_resource
    current_service
  end
end
