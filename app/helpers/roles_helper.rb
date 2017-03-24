module RolesHelper
  def format_roles_for_select(roles)
    roles.map do |key|
      ["#{I18n.t("roles.#{key}.title")}", key, {'data-icon': "#{I18n.t("roles.#{key}.icon")}"}]
    end
  end
end