module Api
  module V1
    class ContractsController < ApiController
      before_action :authorize_owner

      def index
        render json: {
          data: current_service.subtree.map(&:associated_contracts).flatten.map {|contract|
            {
              id: contract.id.to_s,
              type: contract.class.name,
              attributes: {
                code: (authenticated_service.id == contract.startup.id ? contract.startup_code : contract.client_code),
                name: contract.name,
                status: contract.status,
                expected_start_date: contract.expected_start_date,
                expected_end_date: contract.expected_end_date,
                is_evergreen: contract.is_evergreen,
                production: contract.production,
                start_date: contract.start_date,
                end_date: contract.end_date,
                client: {
                  id: contract.client.subdomain,
                  type: contract.client.class.name,
                  attributes: {
                    name: contract.client.name
                  }
                },
                supplier: {
                  id: contract.startup.subdomain,
                  type: contract.startup.class.name,
                  attributes: {
                    name: contract.startup.name
                  }
                },
                proxy: {
                  id: contract.proxy.subdomain,
                  type: contract.proxy.class.name,
                  attributes: {
                    name: contract.proxy.name,
                    description: contract.proxy.description,
                    category: contract.proxy.category.try(:name),
                    routes: contract.proxy.routes.map {|route|
                      {
                        id: route.subdomain,
                        type: route.class.name,
                        attributes: {
                          name: route.name,
                          request_url: route.local_url('v1'),
                          allowed_methods: route.allowed_methods
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      def authorize_owner
        if current_service.id != authenticated_service.id && !(current_service.parent && current_service.parent.id == authenticated_service.id)
          raise BaseForbiddenError
        end
      end
    end
  end
end
