module Api
  class AuthenticationController < ApiController
    def authenticate
      service = Service.find_by_client_id(params[:client_id])
      if !service.nil? && service.client_secret == params[:client_secret]
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
      {
        auth_token: JsonWebToken.encode({service_id: service.id}),
        service: {id: service.id}
      }
    end
  end
end
