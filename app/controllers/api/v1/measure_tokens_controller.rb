module Api
  module V1
    class MeasureTokensController < ApiController
      skip_before_action  :authenticate_schema, only: [:index]
      before_action       :load_measure_tokens
      before_action       :load_measure_token, only: [:show, :revoke]

      def index
        measure_tokens_json = @measure_tokens.map do |measure_token|
          {
            id: measure_token.value,
            type: measure_token.class.name,
            attributes: {
              name: measure_token.value,
              revoked: !measure_token.is_active,
              contract: measure_token.contract.name,
              contract_status: measure_token.contract_status,
            }
          }
        end
        render json: {data: measure_tokens_json}
      end

      def show
        return render json: {
            errors: [{
                         status: 403,
                         title: "Invalid #{Appconfig.get(:api_measure_token_name)}"
                     }]
        } if current_measure_token.nil?
        render json: {
          data: {
            id: current_measure_token.value,
            type: current_measure_token.class.name,
            attributes: {
                name: current_measure_token.value,
                revoked: !current_measure_token.is_active,
                contract: current_measure_token.contract.name,
                contract_status: current_measure_token.contract_status
            }
          }
        }
      end

      def revoke
        return render json: {
            errors: [{
                         status: 403,
                         title: "Invalid #{Appconfig.get(:api_measure_token_name)}"
                     }]
        } if current_measure_token.nil?
        return render json: {
            errors: [{
                         status: 403,
                         title: "Invalid #{Appconfig.get(:api_measure_token_name)}"
                     }]
        } if current_measure_token.nil? unless current_measure_token.is_active
        current_measure_token.is_active = false
        if current_measure_token.save
          render status:200
        else
          render status:500
        end
      end

      private

      def current_measure_token
        @measure_token
      end

      def load_measure_token
        return unless params.key?(:id)
        @measure_token = get_measure_token(params[:id])
      end

      def get_measure_token(value)
        res = @measure_tokens.each do |measure_token|
          return measure_token if measure_token.value == value
        end
        return nil unless res.nil?
        res
      end

      def load_measure_tokens
        @measure_tokens = Contract.associated_services(current_service).each_with_object([]) do |contract, tokens|
          tokens.concat(contract.measure_tokens)
        end.reject(&:blank?).uniq
      end
    end
  end
end
