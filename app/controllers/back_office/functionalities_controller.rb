module BackOffice
  class FunctionalitiesController < BackOfficeController
    before_action :load_functionality_and_authorize, only: [:show, :edit, :update, :destroy, :configure, :save_configuration]

    def index
      @collection = Functionality.authorized(current_user)
    end

    def new
      @functionality = Functionality.new
    end

    def create
      @functionality = Functionality.new
      @functionality.user = current_user
      @functionality.service = current_service
      @functionality.assign_attributes(functionality_params)

      if @functionality.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.functionality'))
        redirect_to back_office_functionality_path(@functionality)
      else
        flash[:error] = @functionality.errors.messages
        render :new
      end
    end

    def edit
    end

    def update
      @functionality.assign_attributes(functionality_params)
      if @functionality.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.functionality'))
        redirect_to back_office_functionality_path(@functionality)
      else
        flash[:error] = @functionality.errors.messages
        render :edit
      end
    end

    def show
    end

    def destroy
    end

    def configure
      if @functionality.proxy_parameter.nil?
        @functionality.build_proxy_parameter
      end
    end

    def save_configuration
      if @functionality.proxy_parameter.nil?
        @functionality.build_proxy_parameter
      end
      @functionality.proxy_parameter.assign_attributes(proxy_parameter_params)
      if @functionality.save
        redirect_to back_office_functionality_path(@functionality)
      else
        flash[:error] = @functionality.proxy_parameter.errors.messages
        render :configure
      end
    end

    def functionality_params
      params.require(:functionality).permit(:name, :description, :type)
    end

    def proxy_parameter_params
      params.require(:proxy_parameter).permit(:authentication_mode, :protocol, :hostname, :port, :authentication_url, :client_id, :client_secret)
    end

    def load_functionality_and_authorize
      @functionality = Functionality.find_by_id(params[:id])
      return redirect_to services_path if @functionality.nil?
      unless @functionality.authorized?(current_user)
        return head(:forbidden)
      end
    end
  end
end
