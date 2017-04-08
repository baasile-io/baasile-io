module InputsHelper
  def format_boolean_values_for_input
    [true, false].map {|v| [t("misc.#{v}"), v]}
  end
end