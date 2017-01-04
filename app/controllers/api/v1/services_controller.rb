module Api
  module V1
    class ServicesController < ApiController
      def index
        services = Service.activated
        services_restrict = services.map do |service|
          {
            id: service.id,
            data: {
                name: service.name,
                description: service.description,
                website: service.website,
                subdomain: service.subdomain
            }
          }
        end
        render json: services_restrict
      end
    end
  end
end
