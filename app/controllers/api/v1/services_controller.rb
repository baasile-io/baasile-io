module Api
  module V1
    class ServicesController < ApiController
      skip_before_action  :authenticate_schema, only: [:index, :root]

      def index
        services = Service.activated_startups.published
        services_restrict = services.map do |service|
          if current_service.nil? || current_service.id != service.id
            get_service_into_json(service)
          end
        end
        render json: {data: services_restrict}
      end

      def root
        raise BaseNotFoundError
      end

      def show
        raise AuthInvalidSubdomainError if current_service.nil?
        render json: get_service_into_json(current_service)
      end

      private

      def get_service_into_json(service)
        {
          data: {
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
        }
      end
    end
  end
end
