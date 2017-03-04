module QueryParametersHelper
  def format_query_parameter_modes_for_select
    QueryParameter::MODES.map do |key, _|
      ["#{I18n.t("types.query_parameter_modes.#{key}")}", key]
    end
  end

  def format_query_parameter_types_for_select
    QueryParameter::QUERY_PARAMETER_TYPES.map do |key, _|
      ["#{I18n.t("types.query_parameter_types.#{key}.title")}", key]
    end
  end
end
