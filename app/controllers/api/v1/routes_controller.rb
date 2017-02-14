module Api
  module V1
    class RoutesController < ApiController
      before_action :load_route, except: [:index]
      before_action :authorize_request!

      # allow proxy functionality
      include RedisStoreConcern
      include ProxifyConcern

      # allow measure functionality
      include MeasurementConcern

      def process_request
        begin
          res = proxy_request
          render status: res.code, plain: res.body
        rescue ProxyInitializationError
          render plain: 'ProxyInitializationError'
        rescue ProxyAuthenticationError => e
          render status: :bad_gateway, plain: "An error occured with the proxy parameters. Please check on your dashboard your configuration.\r\nStatus code: #{e.code}\r\n#{e.body}"
        rescue ProxyRequestError => e
          render status: :bad_gateway, plain: "error code: #{e.code}\r\n\r\n#{e.body}"
        end
      end

      def index
        render json: current_proxy.routes
      end

      def show
        render json: current_route
      end

      def load_route
        if current_route.nil?
          return head :not_found
        end
      end

      def current_proxy
        @current_proxy ||= Proxy.find_by_id(params[:proxy_id])
      rescue
        nil
      end

      def current_route
        @current_route ||= current_proxy.routes.find_by_id(params[:id])
      rescue
        nil
      end

      def authorize_request!
        return true if current_service == authenticated_service
        if authenticated_service.has_role?(:all, current_route) || authenticated_service.has_role?(:all, current_proxy) || authenticated_service.has_role?(:all, current_service)
          return true
        end
        return head :forbidden
      end

    end
  end
end
