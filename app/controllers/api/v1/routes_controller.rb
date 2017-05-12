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
        if metadata_request && metadata_response
          metadata_full = {
            request: metadata_request,
            response: metadata_response
          }
        end
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
          raise BaseNotFoundError
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

      def authorize_request_by_contract
        Contracts::ContractValidationService.new(current_contract, current_route).authorize_request
      rescue Contracts::ContractValidationService::MissingContract
        raise ContractMissingContractError
      rescue Contracts::ContractValidationService::NotValidatedContract
        raise ContractNotValidatedContractError
      rescue Contracts::ContractValidationService::MissingStartDateProductionPhase
        raise ContractMissingStartDateProductionPhaseError
      rescue Contracts::ContractValidationService::NotStartedProductionPhase
        raise ContractNotStartedProductionPhaseError
      rescue Contracts::ContractValidationService::EndedProductionPhase
        raise ContractEndedProductionPhaseError
      rescue Contracts::ContractValidationService::WaitingForProduction
        raise ContractWaitingForProductionError
      rescue Contracts::ContractValidationService::NotActive
        raise ContractNotActiveError
      end

    end
  end
end
