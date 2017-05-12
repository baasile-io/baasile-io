module ApplicationHelper
  def arrange_nested_resources_collection(items, proc_condition = nil)
    result = []
    items.map do |item|
      if proc_condition.nil? || proc_condition.call(item)
        result << item
        #this is a recursive call:
        result += arrange_nested_resources_collection(item.children, proc_condition) {|i| i }
      end
    end
    result
  end

  def link_to_modal(name = nil, url = nil, html_options = nil, &block)
    html_options, url = url, name if block_given?
    html_options ||= {}

    html_options[:data] ||= {}
    html_options[:data][:toggle]    = :modal
    html_options[:data][:target]    = '#modal-window'
    html_options[:data][:keyboard]  = true
    html_options[:data][:backdrop]  = true
    html_options[:remote]           = true

    if block_given?
      link_to url, html_options do
        yield block
      end
    else
      link_to name, url, html_options
    end
  end
end
