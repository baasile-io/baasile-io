module Api
  module V1
    class ServicesController < ApiController
      skip_before_action  :authenticate_schema, only: :index

      def index
        services = Service.published
        services_restrict = services.map do |service|
          {
            id: service.client_id,
            type: service.class.name,
            attributes: {
              name: service.name,
              description: service.description,
              website: service.website,
              identifier: service.subdomain,
              scope: service.subdomain
            }
          }
        end
        render json: services_restrict
      end

      def show
        render json: {
          id: current_service.client_id,
          type: current_service.class.name,
          attributes: {
            name: current_service.name,
            description: current_service.description,
            website: current_service.website,
            identifier: current_service.subdomain,
            scope: current_service.subdomain
          }
        }
      end
    end
  end
end
