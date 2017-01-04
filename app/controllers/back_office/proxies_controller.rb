module BackOffice
  class ProxiesController < BackOfficeController
    before_action :load_proxy_and_authorize, only: [:show, :edit, :update, :destroy]

    def index
      @collection = Proxy.authorized(current_user)
    end

    def new
      @proxy = Proxy.new
      @proxy.build_proxy_parameter
    end

    def create
      @proxy = Proxy.new(proxy_params)
      @proxy.user = current_user
      @proxy.service = current_service

      if @proxy.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.proxy'))
        redirect_to back_office_proxy_path(@proxy)
      else
        flash[:error] = @proxy.errors.messages
        render :new
      end
    end

    def edit
    end

    def update
      if @proxy.update(proxy_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.proxy'))
        redirect_to back_office_proxy_path(@proxy)
      else
        flash[:error] = @proxy.errors.messages
        render :edit
      end
    end

    def show
    end

    def destroy
    end

    def proxy_params
      params.require(:proxy).permit(:name, :description, :alias, proxy_parameter_attributes: [:id, :authentication_mode, :protocol, :hostname, :port, :authentication_url, :realm, :grant_type, :client_id, :client_secret])
    end

    def load_proxy_and_authorize
      @proxy ||= Proxy.find_by_id(params[:id])
      return redirect_to services_path if @proxy.nil?
      unless @proxy.authorized?(current_user)
        return head(:forbidden)
      end
    end

    def current_proxy
      return nil unless params[:id]
      @proxy
    end
  end
end
