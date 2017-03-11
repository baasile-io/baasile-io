class UsersController < ApplicationController
  before_action :authenticate_user!

  include UsersConcern::Controller

  def profile
  end

  def current_module
    params[:service_id] ? 'services' : 'back_office'
  end
end
