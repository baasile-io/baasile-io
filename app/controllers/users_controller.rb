class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service, except: [:profile]
  before_action :load_user_and_authorize_owner, only: [:edit, :update, :destroy]
  before_action :load_user_and_authorize_service_admin, only: [:toggle_role, :disassociate]

  # Authorization
  before_action :authorize_action

  def index
    @owned_users = current_user.children
    if current_service.nil?
      @users = @owned_users
    else
      @users = current_service.users
      @owned_users = @owned_users.to_a.reject {|u| @users.exists?(u) }
    end
  end

  def new
    @user = User.new(parent_id: current_user.id, is_active: true, email: params[:email], language: I18n.locale)
  end

  def create
    @user = User.new(parent_id: current_user.id, is_active: true)
    @user.assign_attributes(user_params)
    assign_random_password
    if @user.save
      if current_service
        ::Users::UserAssociationsService.new(@user).create_association(current_service)
      end
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user'))
      redirect_to_index
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    if @user.save
      if params[:send_reset_password]
        unless ::Users::UserPasswordsService.new(@user).reset_password
          flash[:error] = I18n.t('errors.failed_to_reset_password')
        else
          flash[:success] = I18n.t('back_office.users.create.success_reset_password', pwd: @user.password)
        end
      else
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
      end
      redirect_to_index
    else
      render :new
    end
  end

  def edit
  end

  def destroy
    if !@user.parent || current_user.id != @user.parent.id
      flash[:error] = I18n.t('misc.not_authorized')
    else
      @user.destroy
    end
    redirect_to_index
  end

  def invite_by_id
    user = User.find_by_id(params[:user][:id])
    if ::Users::UserAssociationsService.new(user).create_association(current_service)
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user_association'))
    end
    redirect_to service_users_path(current_service)
  end

  def invite_by_email
    email = params[:email]
    user = User.find_by_email(email)
    if user.nil?
      flash[:error] = I18n.t('misc.unknown_user_create_on')
      return redirect_to new_service_user_path(current_service, email: email) if email.present?
    else
      if ::Users::UserAssociationsService.new(user).create_association(current_service)
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user_association'))
      end
    end
    redirect_to service_users_path(current_service)
  end

  def disassociate
    if [current_service.main_admin, current_service.main_developer, current_service.main_commercial, current_service.main_accountant].include?(@user)
      flash[:error] = t('misc.user_not_disassociable_because_official')
    else
      if UserAssociation.where(user: @user, associable: current_service).destroy_all
        @user.roles.where(resource: current_service).destroy_all
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.user_association'))
      end
    end
    redirect_back(fallback_location: user_path(@user))
  end

  def toggle_role
    scope = params[:scope]
    if current_user == @user
      flash[:error] = "You can't remove your own role"
    else
      if @user.send(@user.has_role?(scope, current_service) ? :remove_role : :add_role, scope, current_service)
        flash[:success] = I18n.t('actions.success.updated', resource: t('misc.role'))
      end
    end

    redirect_back(fallback_location: user_path(@user))
  end

  def redirect_to_index
    return redirect_to service_users_path(current_service) if current_service
    redirect_to users_path
  end

  def assign_random_password
    ::Users::UserPasswordsService.new(@user).assign_random_password
  end

  def profile
  end

  def current_module
    if current_service.nil?
      'profile'
    else
      'dashboard'
    end
  end

  def current_service
    @service
  end

  def load_service
    @service = Service.find(params[:service_id]) if params[:service_id]
  end

  def current_authorized_resource
    current_service
  end

  def user_params
    params.require(:user).permit(:email, :gender, :first_name, :last_name, :phone, :is_active, :language)
  end

  def load_user_and_authorize_service_admin
    @user = User.find(params[:id])
    unless current_user.is_admin_of?(current_service)
      flash[:error] = I18n.t('misc.not_authorized')
      return redirect_to_index
    end
  end

  def load_user_and_authorize_owner
    @user = User.find(params[:id])
    if !@user.parent || current_user.id != @user.parent.id
      flash[:error] = I18n.t('misc.not_authorized')
      return redirect_to_index
    end
  end
end
