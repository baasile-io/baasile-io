class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :autorize_superadmin, only: [:index, :new, :create, :destroy, :desactivate, :activate]
  before_action :load_user, only: [:show, :edit, :update, :set_admin, :unset_admin,:desactivate, :activate]
  before_action :load_user_by_current_user, only: [:profile ]

  def index
    @collection = User.all
  end

  def new
    @user = User.new
  end

  def admin_create
    logger.info "############### in create ###########"
    @user = User.new(new_user_params)
    @user.confirmed_at = DateTime.now
    if @user.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.users'))
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    if @user.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
      if @user != current_user
        redirect_to users_path
      else
        redirect_to profile_path
      end
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def edit
  end

  def profile
  end

  def show
    @services = Service.owned(@user)
  end

  def set_admin
    @user.add_role(:superadmin);
    return redirect_to users_path
  end

  def unset_admin
    @user.remove_role(:superadmin);
    return redirect_to users_path
  end

  def activate
    @user.is_active = true
    @user.save
    return redirect_to users_path
  end

  def desactivate
    @user.is_active = false
    @user.save
    return redirect_to users_path
  end

  def load_user_by_current_user
    @user = current_user
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

  def new_user_params
    allowed_parameters = [:email, :password, :password_confirmation]
    params.require(:user).permit(allowed_parameters)
  end

  def user_params
    allowed_parameters = [:first_name, :last_name, :gender, :phone]
    params.require(:user).permit(allowed_parameters)
  end

  def autorize_superadmin
    return head(:forbidden) unless current_user.has_role?(:superadmin)
  end

  def current_module
    'users'
  end

end
