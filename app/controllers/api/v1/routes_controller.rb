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
          @res = proxy_request
          render status: @res.code, plain: @res.body
        rescue ProxyInitializationError
          render status: :bad_gateway, json: {
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
          if current_service.id == authenticated_service.id || (current_service.parent.present? && current_service.parent.id == authenticated_service.id)
            render status: :bad_gateway, json: {
              errors: [
                {
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
                }
              ]
            }
          else
            render status: :bad_gateway, json: {
              errors: [
                {
                  status: status,
                  title: title,
                  meta: {
                    response: {
                      status: e.code,
                      body: e.body.to_s.force_encoding('UTF-8')
                    }
                  }
                }
              ]
            }
          end
        end
      end

      def index
        render json: {
          data: current_proxy.routes.map {|route|
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
      end

      def show
        render json: {
          data: {
            id: current_route.subdomain,
            type: current_route.class.name,
            attributes: {
              name: current_route.name,
              request_url: current_route.local_url('v1'),
              allowed_methods: current_route.allowed_methods
            }
          }
        }
      end

      def load_route
        if current_route.nil?
          return render status: 404, json: {
            errors: [{
                       status: 404,
                       title: 'Route not found'
                     }]
          }
        end
      end

      def current_proxy
        @current_proxy ||= current_service.proxies.where("subdomain = :subdomain OR id = :id", subdomain: params[:proxy_id].to_s, id: params[:proxy_id].to_i).first
      rescue
        nil
      end

      def current_route
        @current_route ||= current_proxy.routes.where("subdomain = :subdomain OR id = :id", subdomain: params[:id].to_s, id: params[:id].to_i).first
      rescue
        nil
      end

      def authorize_request!
        #TODO
        return true

        if current_service == authenticated_service || authenticated_service.has_role?(:all, current_service) || authenticated_service.has_role?(:all, current_proxy) || authenticated_service.has_role?(:all, current_route)
          return true
        end
        status = 403
        title = 'Client is not authorized to access this route'

        render status: status, json: {
          errors: [{
            status: status,
            title: title
          }]
        }
        return false
      end

    end
  end
end
