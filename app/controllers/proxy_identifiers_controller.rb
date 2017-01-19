class ProxyIdentifiersController < DashboardController
  before_action :authorize_proxy

  def index
    @collection = current_proxy.proxy_identifiers
  end

  def new
    @proxy_identifier = ProxyIdentifier.new
  end

  def current_proxy
    @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
  end
end
