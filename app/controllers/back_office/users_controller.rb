module BackOffice
  class UsersController < BackOfficeController
    before_action :load_user, except: [:index, :new, :create]
    before_action :load_other_users, only: [:new, :edit, :update, :create]

    def index
      @collection = User.all.includes(:services).order('users.last_activity_at DESC NULLS LAST')

      @collection = search   @collection
      @collection = paginate @collection
    end

    def show
      redirect_to edit_back_office_user_path(@user)
    end

    def new
      params[:send_welcome_instructions] = 'true'
      params[:skip_confirmation] = 'true'
      @user = User.new
      @user.is_active = true
    end

    def create
      @user = User.new(user_params)
      assign_random_password
      @user.skip_confirmation! if params[:skip_confirmation]
      if @user.save
        UserNotifier.send_welcome_email(@user, @user.password).deliver_now if params[:send_welcome_instructions]
        flash[:success] = I18n.t('back_office.users.create.success_message', pwd: @user.password)
        redirect_to permissions_back_office_user_path(@user)
      else
        render :new
      end
    end

    def update
      @page_title = @user.full_name
      @user.skip_confirmation! if params[:skip_confirmation]
      if @user.update(user_params)
        if params[:send_reset_password]
          unless ::Users::UserPasswordsService.new(@user).reset_password
            flash[:error] = I18n.t('errors.failed_to_reset_password')
          else
            flash[:success] = I18n.t('back_office.users.create.success_reset_password', pwd: @user.password)
          end
        else
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
        end
        redirect_to back_office_users_path
      else
        render :edit
      end
    end

    def destroy
      if @user.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.user'))
      end
      redirect_to back_office_users_path
    end

    def edit
      @page_title = "#{'<i class="fa fa-fw fa-lock"></i> ' unless @user.confirmed_at}#{@user.full_name}"
    end

    def permissions
      @user_services = @user.services.order('ancestry ASC NULLS FIRST')
      @other_services = Service.where.not(id: @user_services.pluck(:id)).order('services.name ASC')
    end

    def users
      @children_users = @user.children
    end

    def associate
      service = Service.find(params[:user][:service_id])
      role = params[:user][:role].to_sym
      if Role::USER_ROLES.include?(role) && UserAssociation.create(user: @user, associable: service)
        @user.add_role(role, service)
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user_association'))
      end
      redirect_to permissions_back_office_user_path(@user)
    end

    def disassociate
      service = Service.find(params[:service_id])
      if service.user_id == @user.id
        flash[:error] = "You can't remove association because the user is the owner"
      else
        if UserAssociation.where(user: @user, associable: service).destroy_all
          @user.roles.where(resource: service).destroy_all
          flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.user_association'))
        end
      end
      redirect_to permissions_back_office_user_path(@user)
    end

    def toggle_role
      scope = params[:scope]
      if current_user == @user
        flash[:error] = "You can't remove your own role"
      else
        if @user.send(@user.has_role?(scope) ? :remove_role : :add_role, scope)
          flash[:success] = I18n.t('actions.success.updated', resource: t('misc.role'))
        end
      end

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def toggle_object_role
      scope = params[:scope]
      object_type = params[:object_type]
      object_id = params[:object_id]

      object = object_type.constantize.find(object_id)
      if @user.has_role?(scope, object)
        if object.user_id == @user.id && scope.to_sym == :admin
          flash[:error] = "You can't remove administrator role from an object's owner"
        else
          @user.remove_role(scope, object)
        end
      else
        @user.add_role(scope, object)
      end

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def toggle_is_active
      if current_user == @user
        flash[:error] = "You can't deactivate yourself"
      else
        @user.assign_attributes(is_active: !@user.is_active)
        if @user.save(validate: false)
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
        else
          flash[:error] = @user.errors.full_messages.join(', ')
        end
      end

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def sign_in_as
      sign_in(:user, @user, event: :authentication)
      redirect_to root_url
    end

    def unlock_after_expired
      @user.assign_attributes(expired_at: nil, last_activity_at: Time.now.utc)
      if @user.save(validate: false)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
      else
        flash[:error] = @user.errors.full_messages.join(', ')
      end

      redirect_back(fallback_location: back_office_users_path)
    end

    private

    def load_user
      @user = User.find(params[:id])
    end

    def load_other_users
      @users = User.all.reject {|u| u.id == @user.try(:id)}
    end

    def user_params
      allowed_parameters = [:email, :first_name, :last_name, :gender, :phone, :language, :is_active, :parent_id]
      params.require(:user).permit(allowed_parameters)
    end

    def assign_random_password
      ::Users::UserPasswordsService.new(@user).assign_random_password
    end

  end
end