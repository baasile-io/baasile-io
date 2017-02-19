module ProxyParametersHelper
  def format_authorization_modes_for_select
    ProxyParameter::AUTHORIZATION_MODES_ENUM.map do |key, _|
      ["#{I18n.t("types.authorization_modes.#{key}")}", key]
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
