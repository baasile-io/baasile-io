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

  def format_query_parameters_for_select(query_parameters)
    query_parameters.map do |query_parameter|
      ["#{query_parameter.name}", query_parameter.id, {'data-text-right': "<i class=\"fa fa-fw fa-sitemap\"></i> #{query_parameter.route.name}", 'data-description': query_parameter.description, 'data-icon': 'fa fa-fw fa-list'}]
    end
  end
end
