module Api
  module V1
    class TestsController < ApiController
      before_action :load_route, only: [:process_request]

      # allow proxy functionality
      include RedisStoreConcern
      include ProxifyConcern

      def process_request
        @proxy_response = proxy_request
        render status: @proxy_response.code, plain: @proxy_response.body
      rescue Api::ProxyError => e
        Rails.logger.error "Api::ProxyError: #{e.message}"
        if e.req
          metadata_request = {
            method: e.req.method,
            original_url: e.uri.to_s,
            headers: e.req.to_hash,
            body: e.req.body
          }
        end
        if e.res
          metadata_response = {
            status: e.res.code,
            body: e.res.body.to_s.force_encoding('UTF-8')
          }
        end
        metadata_full = {
          request: metadata_request,
          response: metadata_response
        }
        render json: {req: metadata_request, res: metadata_response, uri: e.uri.to_s, message: e.message, meta: e.meta}
      end

      def load_route
        if current_route.nil?
          raise BaseNotFoundError
        end
      end

      def current_route
        @current_route ||= Route.find(params[:route_id])
      end

      def current_proxy
        @current_proxy ||= current_route.proxy
      end

      def current_service
        @current_service ||= authenticate_schema
      end

      def authenticate_schema
        @current_service = current_proxy.service
      end

      def use_test_settings?
        true
      end

      def authenticated_service
        current_service
      end

      def current_measure_token
        nil
      end

    end
  end
end
