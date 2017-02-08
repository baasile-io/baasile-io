module Api
  module V1
    class ServicesController < ApiController
      def index
        services = Service.published
        services_restrict = services.map do |service|
          {
            id: service.id,
            data: {
                name: service.name,
                description: service.description,
                website: service.website,
                identifier: service.subdomain
            }
          }
        end
        render json: services_restrict
      end
    end
  end
end
