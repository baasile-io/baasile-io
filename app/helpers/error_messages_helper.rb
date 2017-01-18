module ErrorMessagesHelper
  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= t('misc.invalid_fields')
    options[:message] ||= t('misc.correct_errors')
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages alert alert-danger") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:h4, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

  module FormBuilderAdditions
    def error_messages(options = {})
      @template.error_messages_for(@object, options)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, ErrorMessagesHelper::FormBuilderAdditions)
