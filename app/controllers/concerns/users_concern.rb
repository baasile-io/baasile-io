module UsersConcern
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action :load_user, except: [:index, :new, :create, :profile]
      before_action :load_parent_users, only: [:new, :create, :edit, :update]
    end

    def index
      @collection = User.authorized(current_user).reject {|u| u.id == current_user.id }
    end

    def permissions
      @services = Service.authorized(current_user)
    end

    def new
      if current_user.is_superadmin?
        params[:send_welcome_instructions] = 'true'
        params[:skip_confirmation] = 'true'
      end
      @user = User.new
      @user.is_active = true
    end

    def create
      @user = User.new(user_params)
      generate_random_password
      @user.password_changed_at = 1.year.ago
      @user.skip_confirmation! if params[:skip_confirmation] && current_user.is_superadmin?
      if @user.save
        UserNotifier.send_welcome_email(@user, @user.password).deliver_now if params[:send_welcome_instructions] || !current_user.is_superadmin?
        flash[:success] = I18n.t('back_office.users.create.success_message', pwd: @user.password)
        redirect_to (current_user.is_superadmin? ? permissions_back_office_user_path(@user) : permissions_user_path(@user))
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
        redirect_to (current_user.is_superadmin? ? back_office_users_path : users_path)
      else
        render :edit
      end
    end

    def generate_random_password
      @user.password_confirmation = @user.password = temporary_password = (('a'..'k').to_a + ('L'..'Z').to_a + ('0'..'9').to_a + ['/', '.', '?', '%']).shuffle.join
    end

    def destroy
      if @user.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.user'))
      end
      redirect_to (current_user.is_superadmin? ? back_office_users_path : users_path)
    end

    def edit
      @page_title = @user.full_name
    end

    def load_user
      @user = User.find(params[:id])
    end

    def load_parent_users
      @parent_users = User.where('ancestry IS NULL').authorized(current_user).reject {|u| u.id == @user.try(:id) }
    end

    def user_params
      allowed_parameters = [:email, :first_name, :last_name, :gender, :phone, :is_active, :parent_id]
      params.require(:user).permit(allowed_parameters)
    end
  end
end