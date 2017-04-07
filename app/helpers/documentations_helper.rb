module DocumentationsHelper
  def format_documentation_types_for_select
    Documentation::DOCUMENTATION_TYPES.map do |documentation_type, _|
      [t("types.documentation_types.#{documentation_type}.title"), documentation_type, {'data-icon': I18n.t("types.documentation_types.#{documentation_type}.icon")}]
    end
  end
end