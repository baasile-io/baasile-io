class ProxyIdentifiersController < DashboardController
  before_action :authorize_proxy

  def index
    @collection = current_proxy.proxy_identifiers
  end

  def new
    @proxy_identifier = ProxyIdentifier.new
  end

  def create
    @proxy_identifier = ProxyIdentifier.new(proxy_identifier_params)
    @proxy_identifier.user = current_user
    @proxy_identifier.proxy = current_proxy

    if @proxy_identifier.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.proxy_identifier'))
      redirect_to service_proxy_proxy_identifiers_path(current_service, current_proxy)
    end
  end

  def current_proxy
    @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
  end

  def proxy_identifier_params
    params.require(:proxy_identifier).permit(:client_id, :client_secret)
  end
end
