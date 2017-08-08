module Api
  module V1
    class ServicesController < ApiController
      skip_before_action  :authenticate_schema, only: [:index, :client_id, :subdomain, :show]

      def index
        services = Service.activated_startups.published
        services_restrict = services.map do |service|
          get_service_into_json(service)
        end
        render json: {data: services_restrict}
      end

      def show
        render json: get_service_into_json(current_service)
      end

      def client_id
        render json: get_service_into_json(current_service_by_client_id)
      end

      def subdomain
        render json: get_service_into_json(current_service_by_subdomain)
      end

      private

      def current_service_by_client_id
        raise AuthMissingClientIdError unless params[:id].present?
        @service = Service.find_by_client_id(params[:id])
        raise AuthInvalidClientIdError if @service.nil?
        @service
      end

      def current_service_by_subdomain
        raise AuthInvalidSubdomainError unless params[:id].present?
        @service = Service.find_by_subdomain(params[:id])
        raise AuthMissingSubdomainError if @service.nil?
        @service
      end

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
