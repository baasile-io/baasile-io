module BackOffice
  class UsersController < BackOfficeController
    include UsersConcern::Controller

    add_breadcrumb I18n.t('back_office.users.index.title'), :back_office_users_path
    before_action :add_breadcrumb_current_action, except: [:index]

    def index
      @collection = User.all.order(email: :asc)
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
  end
end