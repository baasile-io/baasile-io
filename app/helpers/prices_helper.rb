module PricesHelper
  def format_pricing_types_for_select
    Price::PRICING_TYPES.map do |key, _|
      ["#{I18n.t("types.pricing_types.#{key}.name")}", key, {'data-description': I18n.t("types.pricing_types.#{key}.description")}]
    end
  end

  def format_pricing_duration_types_for_select
    Price::PRICING_DURATION_TYPES.map do |key, _|
      [I18n.t("types.pricing_duration_types.#{key}.name"), key, {'data-description': I18n.t("types.pricing_duration_types.#{key}.description")}]
    end
  end
end