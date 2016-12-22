module BackOffice
  class RoutesController < BackOfficeController
    before_action :authorize_functionality
    before_action :load_route, only: [:show, :edit, :update, :destroy]

    def authorize_functionality
      return head(:forbidden) unless current_functionality.authorized?(current_user)
    end

    def index
      @collection = current_functionality.routes.authorized(current_user)
    end

    def new
      @route = Route.new
    end

    def create
      @route = Route.new
      @route.user = current_user
      @route.functionality = current_functionality
      @route.assign_attributes(route_params)

      if @route.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.route'))
        redirect_to back_office_functionality_route_path(@route.functionality, @route)
      else
        flash[:error] = @route.errors.messages
        render :new
      end
    end

    def edit
    end

    def update
      @route.assign_attributes(route_params)
      if @route.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.route'))
        redirect_to back_office_functionality_route_path(@route.functionality, @route)
      else
        flash[:error] = @route.errors.messages
        render :edit
      end
    end

    def show
    end

    def destroy
    end

    def route_params
      params.require(:route).permit(:name, :description, :url, :protocol, :hostname, :port)
    end

    def current_functionality
      @current_functionality ||= Functionality.find_by_id(params[:functionality_id])
    end

    def load_route
      @route = Route.find_by_id(params[:id])
      return redirect_to services_path if @route.nil?
    end
  end
end
