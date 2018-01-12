class PhoneNumberInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:data] ||= {}
    input_html_options[:type] = "hidden"

    object_name = @builder.object_name.to_s
    super + template.content_tag(:input,
                                 nil,
                                 {
                                   value: @builder.object.send(attribute_name),
                                   name: "#{object_name}_#{attribute_name}_intl_phone_number",
                                   class: 'intl-tel-input form-control string',
                                   data: {
                                     hidden_input: "#{object_name}[#{attribute_name}]"
                                   }
                                 })
  end
end