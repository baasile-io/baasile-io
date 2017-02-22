module Api
  module V1
    class RoutesController < ApiController
      before_action :load_route, except: [:index]
      before_action :authorize_request!

      # allow proxy functionality
      include RedisStoreConcern
      include ProxifyConcern

      def process_request
        begin
          res = proxy_request
          render status: res.code, plain: res.body
        rescue ProxyInitializationError
          render status: :internal_server_error, json: {
            errors: [{
              status: 591,
              title: 'The server cannot process the request due to a configuration error'
           }]
          }
        rescue ProxyAuthenticationError, ProxyRedirectionError, ProxyRequestError => e
          if e.code >= 500
            status = 595
            title = 'The origin server cannot or will not process the request due to an apparent internal error'
          elsif e.code >= 400
            status = 594
            title = 'The origin server cannot or will not process the request due to an apparent client error'
          else
            status = 593
            title = 'The origin server cannot or will not process the request due to an apparent redirection error'
          end
          render status: :bad_gateway, json: {
            errors: [{
              status: status,
              title: title,
              meta: {
                request: {
                  method: e.req.method,
                  original_url: e.uri.to_s,
                  headers: e.req.to_hash,
                  body: e.req.body
                },
                response: {
                  status: e.code,
                  body: e.body.to_s.force_encoding('UTF-8')
                }
              }
            }]
          }
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
