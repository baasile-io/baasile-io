module Api
  module V1
    class ProxiesController < ApiController
      before_action :load_proxy_and_authorize, except: [:index]

      def show
        render json: {
          id: current_proxy.subdomain,
          type: current_proxy.class.name,
          attributes: {
            name: current_proxy.name
          }
        }
      end

      def index
        render json: current_service.proxies.map {|proxy|
          {
            id: proxy.subdomain,
            type: proxy.class.name,
            attributes: {
              name: proxy.name
            }
          }
        }
      end

      def load_proxy_and_authorize
        @proxy = current_service.proxies.where("subdomain = :subdomain OR id = :id", subdomain: params[:id], id: params[:id].to_i).first
        if @proxy.nil?
          return render status: 404, json: {
            errors: [{
                       status: 404,
                       title: 'Proxy not found'
                     }]
          }
        end
      end

      def current_proxy
        @proxy
      end
    end
  end
end
