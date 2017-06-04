module Api
  module V1
    class ServicesController < ApiController
      skip_before_action  :authenticate_schema, only: :index

      def index
        services = Service.activated_startups.published
        services_restrict = services.map do |service|
          {
            id: service.subdomain,
            type: service.class.name,
            attributes: {
              name: service.name,
              description: service.description,
              website: service.website,
              logotype: service.logotype_url(current_host),
              proxies: service.proxies.map {|proxy|
                {
                  id: proxy.subdomain,
                  type: proxy.class.name,
                  attributes: {
                    name: proxy.name,
                    description: proxy.description,
                    category: proxy.category.try(:name)
                  }
                }
              }
            }
          }
        end
        render json: {data: services_restrict}
      end

      def show
        render json: {
          data: {
            id: current_service.subdomain,
            type: current_service.class.name,
            attributes: {
              name: current_service.name,
              description: current_service.description,
              website: current_service.website,
              logotype: current_service.logotype_url(current_host),
              proxies: current_service.proxies.map {|proxy|
                {
                  id: proxy.subdomain,
                  type: proxy.class.name,
                  attributes: {
                    name: proxy.name,
                    description: proxy.description,
                    category: proxy.category.try(:name)
                  }
                }
              }
            }
          }
        }
      end
    end
  end
end
