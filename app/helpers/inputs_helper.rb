module InputsHelper
  def format_boolean_values_for_input(translations = {})
    [true, false].map {|v|
      [
        (translations.has_key?(v.to_s.to_sym) ? translations[v.to_s.to_sym] : t("misc.#{v}")),
        v
      ]
    }
  end
end