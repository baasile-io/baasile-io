module ProxiesHelper
  def format_proxies_for_select(proxies)
    proxies.map do |proxy|
      [proxy.name, proxy.id, {'data-icon': "fa fa-fw fa-sitemap", 'data-description': proxy.description, 'data-text-right': "<span class=\"#{I18n.t("types.service_types.#{proxy.service.service_type}.class")}\"><i class=\"#{I18n.t("types.service_types.#{proxy.service.service_type}.icon")}\"></i>#{proxy.service.name}</span>"}]
    end
  end
end
