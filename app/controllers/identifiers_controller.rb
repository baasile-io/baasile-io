class IdentifiersController < DashboardController
  before_action :authorize_proxy

  def index
    @collection = []
    @collection << current_proxy.proxy_parameter.identifier if current_proxy.proxy_parameter.identifier
    @collection.map(&:decrypt_secret) if params[:show_secret] == 'true' && @collection.size > 0
  end

  def current_proxy
    @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
  end

  def authorize_proxy
    return head(:forbidden) unless current_proxy.authorized?(current_user)
  end
end
