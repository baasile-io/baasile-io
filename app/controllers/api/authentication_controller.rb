module Api
  class AuthenticationController < ApiController
    skip_before_action :authenticate_schema

    def authenticate
      service = Service.find_by_client_id(params[:client_id])
      if !service.nil? && service.is_activated? && service.client_secret == params[:client_secret]
        render json: payload(service)
      else
        render json: {errors: ['Invalid ID/SECRET']}, status: :unauthorized
      end
    end

    def check_token
      authenticate_request!
      render json: {status: 'ok'}
    end

    private

    def payload(service)
      return nil unless service and service.id
      exp = Time.now.to_i + 4 * 3600
      payload = { service_id: service.id, exp: exp }
      {
        auth_token: JsonWebToken.encode(payload)
      }
    end
  end
end
