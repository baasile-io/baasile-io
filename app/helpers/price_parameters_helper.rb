
module PriceParametersHelper
  def format_price_parameters_type_for_select
    PriceParameter::PRICE_PARAMETERS_TYPES.map do |key, _|
      ["#{I18n.t("types.price_parameters_types.#{key}")}", key]
    end
  end
end