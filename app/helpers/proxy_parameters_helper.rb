module ProxyParametersHelper
  def format_authentication_modes_for_select
    ProxyParameter::AUTHENTICATION_MODES_ENUM.map do |key, _|
      ["#{I18n.t("types.authentication_modes.#{key}")}", key]
    end
  end

  def format_protocols_for_radio_buttons
    ProxyParameter::PROTOCOLS.map do |key, _|
      ["#{I18n.t("types.protocols.#{key}")}", key]
    end
  end
  def format_protocols_for_select
    format_protocols_for_radio_buttons
  end

end
