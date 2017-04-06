module Api
  module V1
    class ContractsController < ApiController
      before_action :load_contract_and_authorize, except: [:index]

      def index
        render json: current_service.subtree.map(&:associated_contracts).flatten.map {|contract|
          {
            id: contract.id.to_s,
            type: contract.class.name,
            attributes: {
              code: contract.code,
              name: contract.name,
              status: contract.status,
              expected_start_date: contract.expected_start_date,
              expected_end_date: contract.expected_end_date,
              is_evergreen: contract.is_evergreen,
              production: contract.production,
              start_date: contract.start_date,
              end_date: contract.end_date,
              client: {
                id: contract.client.client_id,
                type: contract.client.class.name,
                attributes: {
                  name: contract.client.name,
                  identifier: contract.client.subdomain,
                  scope: contract.client.subdomain
                }
              },
              supplier: {
                id: contract.startup.client_id,
                type: contract.startup.class.name,
                attributes: {
                  name: contract.startup.name,
                  identifier: contract.startup.subdomain,
                  scope: contract.startup.subdomain
                }
              },
              product: {
                id: contract.proxy.subdomain,
                type: contract.proxy.class.name,
                attributes: {
                  name: contract.proxy.name
                }
              },
              routes: contract.proxy.routes.map {|route|
                {
                  id: route.subdomain,
                  type: route.class.name,
                  attributes: {
                    name: route.name,
                    request_url: route.local_url('v1')
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
