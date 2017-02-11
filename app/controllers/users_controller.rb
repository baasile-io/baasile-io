class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
  end

  def current_module
    'profile'
  end
end
