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
end
