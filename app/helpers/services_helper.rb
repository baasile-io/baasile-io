module ServicesHelper

  def type_acces_to(service_owner, service_target)
    if  service_owner.has_role? :all, service_target
      return "all"
    else
      return "no"
    end
  end

  def format_service_types_for_select
    Service::SERVICE_TYPES.map do |key, _|
      ["#{I18n.t("types.service_types.#{key}.title")}", key, {'data-class': "#{t("types.service_types.#{key}.class")}", 'data-icon': "#{I18n.t("types.service_types.#{key}.icon")}", 'data-description': "#{I18n.t("types.service_types.#{key}.description")}"}]
    end
  end

  def format_services_for_select(services)
    services.map do |s|
      [s.name, s.id, {'data-type': s.service_type, 'data-class': "#{t("types.service_types.#{s.service_type}.class")}", 'data-description': s.description, 'data-parent': s.parent, 'data-parent-type': s.parent.try(:service_type), 'data-text-right': "#{" <i class=\"fa fa-lock\"></i> #{t('misc.unconfirmed')}</span>" unless s.is_activated?}"}]
    end
  end

end
