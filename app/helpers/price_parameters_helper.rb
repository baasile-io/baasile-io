module PriceParametersHelper
  def format_price_parameter_types_for_select
    PriceParameter::PRICE_PARAMETERS_TYPES.map do |key, _|
      [I18n.t("types.price_parameters_types.#{key}.title"), key, 'data-description': I18n.t("types.price_parameters_types.#{key}.description")]
    end
  end
end