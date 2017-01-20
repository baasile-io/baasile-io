class UsersController < ApplicationController

  before_action :is_super_admin, only: [:index]
  before_action :load_user, only: [:show]

  def index
    @collection = User.all
  end

  def show_profile
    @user = current_user
  end

  def show
    @services = Service.authorized(@user)
  end

  def load_user
    @user = User.find_by_id(params[:id])
    if current_user.has_role?(:superadmin)
      if @user.nil?
        return redirect_to users_path
      end
    else
      if @user.nil? || @user != current_user
        return redirect_back
      end
    end
  end

  def is_super_admin
    return head(:forbidden) unless current_user.has_role?(:superadmin)
  end

end
