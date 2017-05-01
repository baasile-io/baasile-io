module Api
  module V1
    class RoutesController < ApiController
      before_action :load_route, except: [:index]
      before_action :load_contract, except: [:show, :index]
      before_action :authorize_request!
      before_action :authorize_request_by_contract, only: [:process_request]

      # allow proxy functionality
      include RedisStoreConcern
      include ProxifyConcern

      # allow measure functionality
      include MeasurementConcern

      # add erreur measure functionality by adding methode "do_request_Error_measure(title, message, error_type, request)"
      include ErreurMeasurementConcern

      def process_request
          @proxy_response = proxy_request
          render status: @proxy_response.code, plain: @proxy_response.body
      rescue ProxyInitializationError
        do_request_Error_measure(:ProxyInitializationError, @proxy_response)
        render status: :bad_gateway, json: {
          errors: [{
            status: 591,
            title: 'The server cannot process the request due to a configuration error'
         }]
        }
      rescue ProxyAuthenticationError, ProxyRedirectionError, ProxyRequestError => e
        if e.code >= 500
          do_request_Error_measure(:ProxyRequestError, @proxy_response)
          status = 595
          title = 'The origin server cannot or will not process the request due to an apparent internal error'
        elsif e.code >= 400
          do_request_Error_measure(:ProxyAuthenticationError, @proxy_response)
          status = 594
          title = 'The origin server cannot or will not process the request due to an apparent client error'
        else
          do_request_Error_measure(:ProxyRedirectionError, @proxy_response)
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
      rescue ProxyMissingMandatoryQueryParameterError => e
        do_request_Error_measure(:ProxyMissingMandatoryQueryParameterError, @proxy_response, "Missing mandatory #{t("types.query_parameter_types.#{e.query_parameter_type}.title")} parameter: \"#{e.parameter}\"")
        return render status: 400, json: {
          errors: [{
                     status: 400,
                     title: "Missing mandatory #{t("types.query_parameter_types.#{e.query_parameter_type}.title")} parameter: \"#{e.parameter}\""
                   }]
        }
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

      def current_contract
        @contract ||= load_contract
      end

      def current_price
        @price ||= current_contract.price
      end

      def current_contract_status
        @current_contract_status ||= current_contract.status.to_sym
      end

      def current_contract_pricing_type
        @current_contract_pricing_type ||= current_price.pricing_type.to_sym
      end

      def current_contract_pricing_duration_type
        @current_contract_pricing_duration_type ||= current_price.pricing_duration_type.to_sym
      end

      def current_contract_price_request_limit
        @current_contract_price_request_limit ||= case current_contract_pricing_type
                                                    when :per_parameter
                                                      if current_route.measure_token_activated
                                                        if current_price.deny_after_free_count
                                                          current_price.free_count
                                                        else
                                                          false
                                                        end
                                                      else
                                                        false
                                                      end
                                                    when :per_call
                                                      if current_price.deny_after_free_count
                                                        current_price.free_count
                                                      else
                                                        false
                                                      end
                                                    else
                                                      false
                                                  end
      end

      def load_contract
        @contract = Contract.where(client: authenticated_service, proxy: current_proxy).first
      end

      def authorize_request!
        #TODO

        return true
        if current_service == authenticated_service || authorize_request_by_contract
          return true
        end
      end

      def authorize_request_by_contract
        status, error = Contracts::ContractValidationService.new(current_contract, current_route).authorize_request
        return true if status

        error_status = 403
        render status: error_status, json: {
          errors: [{
                     status: error_status,
                     title: error
                   }]
        }
        false
      end

    end
  end
end
