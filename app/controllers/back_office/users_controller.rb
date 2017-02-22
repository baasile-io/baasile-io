module BackOffice
  class UsersController < BackOfficeController
    before_action :load_user, except: [:index, :new, :create]

    add_breadcrumb I18n.t('back_office.users.index.title'), :back_office_users_path
    before_action :add_breadcrumb_current_action, except: [:index]

    def index
      @collection = User.all.order(email: :asc)
    end

    def new
      params[:send_welcome_instructions] = 'true'
      params[:skip_confirmation] = 'true'
      @user = User.new
      @user.is_active = true
    end

    def create
      @user = User.new(user_params)
      generate_random_password
      @user.password_changed_at = 1.year.ago
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
      generate_random_password if params[:send_reset_password]
      if @user.update(user_params)
        if params[:send_reset_password]
          UserNotifier.send_reset_password(@user, @user.password).deliver_now
          flash[:success] = I18n.t('back_office.users.create.success_reset_password', pwd: @user.password)
        else
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
        end
        redirect_to back_office_users_path
      else
        render :edit
      end
    end

    def generate_random_password
      @user.password_confirmation = @user.password = temporary_password = (('a'..'k').to_a + ('L'..'Z').to_a + ('0'..'9').to_a + ['/', '.', '?', '%']).shuffle.join
    end

    def destroy
      if @user.destroy
        flash[:success] = "User deleted"
      end
      redirect_to back_office_users_path
    end

    def edit
      @page_title = @user.full_name
    end

    def permissions
      @services = Service.includes(:company).order('companies.name ASC NULLS FIRST')
    end

    def toggle_role
      scope = params[:scope]
      if current_user == @user
        flash[:error] = "You can't remove your own role"
      else
        @user.send(@user.has_role?(scope) ? :remove_role : :add_role, scope)
      end

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def toggle_object_role
      scope = params[:scope]
      object_type = params[:object_type]
      object_id = params[:object_id]

      object = object_type.constantize.find(object_id)
      @user.send(@user.has_role?(scope, object) ? :remove_role : :add_role, scope, object)

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def toggle_is_active
      if current_user == @user
        flash[:error] = "You can't deactivate yourself"
      else
        @user.update(is_active: !@user.is_active)
      end

      redirect_back(fallback_location: permissions_back_office_user_path(@user))
    end

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      allowed_parameters = [:email, :first_name, :last_name, :gender, :phone, :is_active]
      params.require(:user).permit(allowed_parameters)
    end

  end
end