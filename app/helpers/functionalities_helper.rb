module FunctionalitiesHelper
  def format_functionality_types_for_select
    Functionality::FUNCTIONALITY_TYPES.map do |key, _|
      ["#{I18n.t("types.functionality_types.#{key}")}", key]
    end
  end
end
