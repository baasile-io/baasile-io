module Api
  module V1
    class ProxiesController < ApiController
      before_action :load_proxy_and_authorize, except: [:index]

      def show
        render json: {
          data: {
            id: current_proxy.subdomain,
            type: current_proxy.class.name,
            attributes: {
              name: current_proxy.name,
              description: current_proxy.description,
              category: current_proxy.category.try(:name)
            }
          }
        }
      end

      def index
        render json: {
          data: current_service.proxies.map {|proxy|
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
      end

      def load_proxy_and_authorize
        @proxy = current_service.proxies.where("lower(subdomain) = lower(:subdomain) OR id = :id", subdomain: params[:id].to_s, id: params[:id].to_i).first
        if @proxy.nil?
          raise Api::BaseNotFoundError
        end
      end

      def current_proxy
        @proxy
      end
    end
  end
end
