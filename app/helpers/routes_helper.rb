module RoutesHelper
  def format_routes_for_select(routes)
    routes.map do |route|
      [route.name, route.id, {'data-description': route.description, 'data-icon': 'fa fa-fw fa-sitemap'}]
    end
  end
end