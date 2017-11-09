class JsonInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:data] ||= {}
    input_html_options[:type] = "hidden"

    object_name = @builder.object_name.to_s.gsub(/\[(.*?)\]/, '_\\1')
    super + template.content_tag(:pre,
                                 @builder.object.send(attribute_name),
                                 {
                                   id: "#{object_name}_#{attribute_name}_editor",
                                   class: 'ace-editor',
                                   data: {
                                     format: "json",
                                     target: "#{object_name}_#{attribute_name}",
                                   }
                                 })
  end
end