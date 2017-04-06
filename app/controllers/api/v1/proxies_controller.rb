module Api
  module V1
    class ProxiesController < ApiController
      before_action :load_proxy_and_authorize, except: [:index]

      def show
        render json: @proxy
      end

      def index
        render json: current_service.proxies
      end

      def load_proxy_and_authorize
        @proxy = current_service.where("subdomain = :subdomain OR id = :subdomain", subdomain: params[:id]).first
        if @proxy.nil?
          return render status: 404, json: {
            errors: [{
                       status: 404,
                       title: 'Proxy not found'
                     }]
          }
        end
      end
    end
  end
end
