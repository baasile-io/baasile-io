class TrixEditorInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input_html_options[:type] = "hidden"
    trix_editor_limited = input_html_options[:trix_editor_limited]

    object_name = @builder.object_name.gsub(/\[(.*?)\]/, '_\\1')
    template.content_tag 'div', {class: "trix-editor-container #{'trix-editor-limited' if trix_editor_limited}"} do
      super + template.content_tag(:'trix-editor', nil, {class: "trix-content", input: "#{object_name}_#{attribute_name}"})
    end
  end
end