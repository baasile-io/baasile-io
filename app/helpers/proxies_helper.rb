module ProxiesHelper
  def format_proxies_for_select(proxies)
    proxies.map do |proxy|
      [proxy.service_proxy_name, proxy.id, {'data-icon': "fa fa-fw fa-sitemap"}]
    end
  end
end
