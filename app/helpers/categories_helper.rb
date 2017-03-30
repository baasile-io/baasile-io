module CategoriesHelper
  def format_categories_for_select(categories)
    categories.map do |category|
      [category.name, category.id, 'data-icon': 'fa fa-fw fa-folder-open', 'data-description': category.description]
    end
  end
end