module ServicesHelper

  def type_acces_to(service_owner, service_target)
    if  service_owner.has_role? :all, service_target
      return "all"
    else
      return "no"
    end
  end

  def format_kind_of_for_select
    Service::KINDOF.map do |key, _|
      ["#{I18n.t("types.service_kind_of.#{key}")}", key]
    end
  end

end
