module ApplicationHelper
  def arrange_nested_resources_collection(items)
    result = []
    items.map do |item|
      result << item
      #this is a recursive call:
      result += arrange_nested_resources_collection(item.children) {|i| i }
    end
    result
  end
end
