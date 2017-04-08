module ApplicationHelper
  def arrange_nested_resources_collection(items, condition = nil)
    result = []
    items.map do |item|
      if condition.nil? || condition.call(item)
        result << item
        #this is a recursive call:
        result += arrange_nested_resources_collection(item.children, condition) {|i| i }
      end
    end
    result
  end
end
