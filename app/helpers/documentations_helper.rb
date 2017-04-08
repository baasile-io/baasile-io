module DocumentationsHelper
  def format_documentation_types_for_select
    Documentation::DOCUMENTATION_TYPES.map do |documentation_type, _|
      [t("types.documentation_types.#{documentation_type}.title"), documentation_type, {'data-icon': I18n.t("types.documentation_types.#{documentation_type}.icon")}]
    end
  end

  def format_nested_documentations_for_select(items, current_id = nil, previous_disabled = false)
    result = []
    items.map do |item|
      disabled = (previous_disabled ? previous_disabled : (item.id == current_id))
      result << [item.name, item.id, {'data-depth': item.depth, 'data-icon': I18n.t("types.documentation_types.#{item.documentation_type}.icon"),disabled: disabled}]
      result += format_nested_documentations_for_select(item.children, current_id, disabled) if item.has_children?
    end
    result
  end
end