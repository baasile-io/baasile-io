class IdentifiersController < DashboardController
  def index
    @collection = []
    @collection << current_proxy.proxy_parameter_test.identifier if current_proxy&.proxy_parameter_test&.identifier
    @collection << current_proxy.proxy_parameter.identifier if current_proxy&.proxy_parameter&.identifier
    @collection.map(&:decrypt_secret) if params[:show_secret] == 'true' && @collection.size > 0
  end

  def current_proxy
    @current_proxy ||= Proxy.find(params[:proxy_id])
  end
end
