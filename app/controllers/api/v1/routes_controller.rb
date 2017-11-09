module Api
  module V1
    class RoutesController < ApiController
      before_action :load_route, except: [:index]
      before_action :load_contract, except: [:show, :index]
      before_action :authorize_request_by_contract, only: [:process_request]

      # allow proxy functionality
      include RedisStoreConcern
      include ProxifyConcern

      # allow measure functionality
      include MeasurementConcern

      # add erreur measure functionality by adding methode "do_request_Error_measure(title, message, error_type, request)"
      include ErrorMeasurementConcern

      def process_request

        @use_test_settings = use_test_settings?

        @request_headers = {}
        request.headers.env.select{|k, _| k =~ /^HTTP_/}.each do |header|
          header_name =  header[0].sub(/^HTTP_/, '').gsub(/_/, '-')
          @request_headers[header_name] = header[1]
        end
        @request_method = request.method
        @request_method_symbol = request.method_symbol
        @request_content_type = request.content_type
        @request_body = request.raw_post
        @request_get = request.GET

        proxy_initialize
        @proxy_response = proxy_request

        render status: @proxy_response.code, plain: @proxy_response.body

      rescue Api::ProxyError => e
        Rails.logger.error "Api::ProxyError: #{e.message}"
        if e.req
          metadata_request = {
            method: e.req.method,
            original_url: e.uri.to_s,
            headers: e.req.to_hash.transform_values {|v| v.join(', ')},
            body: e.req.body
          }
        end
        if e.res
          metadata_response = {
            status: e.res.code,
            headers: e.res.to_hash.transform_values {|v| v.join(', ')},
            body: e.res.body.to_s.force_encoding('UTF-8')
          }
        end
        metadata_full = {
          request: metadata_request,
          response: metadata_response
        }
        if current_service.id == authenticated_service.id || (current_service.parent.present? && current_service.parent.id == authenticated_service.id)
          meta = metadata_full
        else
          meta = {
            response: metadata_response
          }
        end
        raise ProxyCanceledMeasurement, {error: e, meta: meta, request_detail: metadata_full}
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
                allowed_methods: route.allowed_methods,
                query_parameters: route.query_parameters.map {|query_parameter|
                  {
                    name: query_parameter.name,
                    description: query_parameter.description,
                    mode: query_parameter.mode,
                    type: query_parameter.query_parameter_type,
                    default_value: query_parameter.default_value
                  }
                }
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
              allowed_methods: current_route.allowed_methods,
              query_parameters: current_route.query_parameters.map {|query_parameter|
                {
                  name: query_parameter.name,
                  description: query_parameter.description,
                  mode: query_parameter.mode,
                  type: query_parameter.query_parameter_type,
                  default_value: query_parameter.default_value
                }
              }
            }
          }
        }
      end

      def load_route
        if current_route.nil?
          raise BaseNotFoundError
        end
      end

      def current_proxy
        @current_proxy ||= current_service.proxies.where("lower(subdomain) = lower(:subdomain) OR id = :id", subdomain: params[:proxy_id].to_s, id: params[:proxy_id].to_i).first
      rescue
        nil
      end

      def current_route
        @current_route ||= current_proxy.routes.where("lower(subdomain) = lower(:subdomain) OR id = :id", subdomain: params[:id].to_s, id: params[:id].to_i).first
      rescue
        nil
      end

      def current_price
        @price ||= current_contract.price
      end

      def use_test_settings?
        current_contract_status != :validation_production
      end

      def current_contract_status
        @current_contract_status ||= current_contract.status.to_sym
      end

      def current_contract_pricing_type
        @current_contract_pricing_type ||= current_price.pricing_type.to_sym
      end

      def current_contract
        @contract ||= load_contract
      end

      def load_contract
        @contract = Contract.where(client: authenticated_service, proxy: current_proxy).first
      end

      def authorize_request_by_contract
        Contracts::ContractValidationService.new(current_contract, current_route).authorize_request
      rescue Contracts::ContractValidationService::MissingContract
        do_request_error_measure(ContractMissingContractError.new, {})
        raise ContractMissingContractError
      rescue Contracts::ContractValidationService::NotValidatedContract
        do_request_error_measure(ContractNotValidatedContractError.new, {})
        raise ContractNotValidatedContractError
      rescue Contracts::ContractValidationService::MissingStartDateProductionPhase
        do_request_error_measure(ContractMissingStartDateProductionPhaseError.new, {})
        raise ContractMissingStartDateProductionPhaseError
      rescue Contracts::ContractValidationService::NotStartedProductionPhase
        do_request_error_measure(ContractNotStartedProductionPhaseError.new, {})
        raise ContractNotStartedProductionPhaseError
      rescue Contracts::ContractValidationService::EndedProductionPhase
        do_request_error_measure(ContractEndedProductionPhaseError.new, {})
        raise ContractEndedProductionPhaseError
      rescue Contracts::ContractValidationService::WaitingForProduction
        do_request_error_measure(ContractWaitingForProductionError.new, {})
        raise ContractWaitingForProductionError
      rescue Contracts::ContractValidationService::NotActive
        do_request_error_measure(ContractNotActiveError.new, {})
        raise ContractNotActiveError
      end

    end
  end
end
