module UsersHelper
  def format_languages_for_select
    I18n.available_locales.map do |key|
      ["#{I18n.t("misc.locales.#{key}")}", key]
    end
  end

  def format_genders_for_select
    User::GENDERS.map do |key, _|
      ["#{I18n.t("types.genders.#{key}")}", key]
    end
  end

  def format_users_for_select(users)
    users.map do |u|
      user_main_role = :superadmin if u.has_role?(:superadmin)
      user_main_role ||= :admin if u.has_role?(:admin)
      [u.full_name, u.id, {'data-icon': 'fa fa-fw fa-user', 'data-description': u.email, 'data-text-right': ("<i class=\"#{I18n.t("roles.#{user_main_role}.icon")}\"></i> #{I18n.t("roles.#{user_main_role}.title")}" if user_main_role)}]
    end
  end
end
