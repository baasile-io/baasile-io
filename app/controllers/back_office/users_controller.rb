module BackOffice
  class UsersController < BackOfficeController
    before_action :load_user, except: [:index, :new, :create]

    def index
      @collection = User.all.order(email: :asc)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        @user.password_confirmation = @user.password = SecureRandom.hex(32)
        @user.save!
        @user.send_confirmation_instructions
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user'))
        redirect_to back_office_users_path
      else
        render :new
      end
    end

    def update
      if @user.update(user_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.user'))
        redirect_to back_office_users_path
      else
        render :edit
      end
    end

    def destroy
      flash[:success] = "User deleted"
      redirect_to back_office_users_path
    end

    def edit
    end

    def permissions
      @companies = Company.all
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

    def toggle_company_role
      scope = params[:scope]
      company = Company.find(params[:company_id])
      @user.send(@user.has_role?(scope, company) ? :remove_role : :add_role, scope, company)

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

    def current_module
      'users'
    end

  end
end