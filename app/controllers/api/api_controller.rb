module Api
  class ApiController < ActionController::Base
    helper_method :current_service

    protected
    def authenticate_request!
      unless service_id_in_token?
        render json: { errors: ['Not Authenticated'] }, status: :unauthorized
        return
      end
      @current_service = Service.find(auth_token[:service_id])
    rescue JWT::VerificationError, JWT::DecodeError
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end

    private
    def http_token
      @http_token ||= if request.headers['Authorization'].present?
                        request.headers['Authorization'].split(' ').last
                      end
    end

    def auth_token
      @auth_token ||= JsonWebToken.decode(http_token)
    end

    def service_id_in_token?
      http_token && auth_token && auth_token[:service_id].to_i
    end

    def current_service
      @current_service ||= Service.find_by_subdomain(Apartment::Tenant.current_tenant)
    end
  end
end
