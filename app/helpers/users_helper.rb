module UsersHelper
  def format_gender_for_select
    User::GENDERS.map do |key, _|
      ["#{I18n.t("types.user_genders.#{key}")}", key]
    end
  end
end