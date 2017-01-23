module Api
  module V1
    class ProxiesController < ApiController
      before_action :authenticate_request!
      before_action :load_proxy_and_authorize, except: [:index]

      def show
        render json: @proxy
      end

      def index
        render json: current_service.proxies
      end

      def load_proxy_and_authorize
        @proxy = Proxy.find_by_id(params[:id])
        if @proxy.nil?
          return head :not_found
        else
          if current_service.id != @proxy.service.id && !(current_service.has_role?(:get, @proxy) || current_service.has_role?(:get, @proxy.service))
            return head :forbidden
          end
        end
      end
    end
  end
end
