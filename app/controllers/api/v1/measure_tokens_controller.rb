module Api
  module V1
    class MeasureTokensController < ApiController
      before_action :authorize_owner
      before_action :load_measure_tokens, only: [:index]
      before_action :load_measure_token, only: [:show]

      def index
        render json: {
          data: @measure_tokens.map do |measure_token|
            {
              id: measure_token.value,
              type: measure_token.class.name,
              attributes: {
                revoked: measure_token.revoked,
                contract_id: "#{measure_token.contract.id}",
                contract_status: measure_token.contract_status
              }
            }
          end
        }
      end

      def show
        render json: {
          data: {
            id: current_measure_token.value,
            type: current_measure_token.class.name,
            attributes: {
              revoked: current_measure_token.revoked,
              contract_id: "#{current_measure_token.contract.id}",
              contract_status: current_measure_token.contract_status
            }
          }
        }
      end

      def revoke
        @measure_token = current_service.measure_tokens.includes(:startup).find_by_value(params[:id])
        raise MeasureTokenNotFoundError if @measure_token.nil?
        raise BaseForbiddenError unless (@measure_token.startup.id == authenticated_service.id) ||
          (@measure_token.startup.parent && @measure_token.startup.parent.id == authenticated_service.id)
        unless current_measure_token.update(is_active: false)
          raise MeasureTokenUnprocessableEntityError
        end
        show
      end

      private

      def current_measure_token
        raise MeasureTokenNotFoundError if @measure_token.nil?
        @measure_token
      end

      def load_measure_token
        @measure_token = current_service.measure_tokens.find_by_value(params[:id])
      end

      def load_measure_tokens
        @measure_tokens = current_service.measure_tokens
      end

      def authorize_owner
        if current_service.id != authenticated_service.id && !(current_service.parent && current_service.parent.id == authenticated_service.id)
          raise BaseForbiddenError
        end
      end
    end
  end
end
