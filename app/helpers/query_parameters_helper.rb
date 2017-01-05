module QueryParametersHelper
  def format_mode_for_select
    QueryParameter::MODES.map do |key, _|
      ["#{I18n.t("types.modes.#{key}")}", key]
    end
  end
end
