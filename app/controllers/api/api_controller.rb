module Api
  class ApiController < ActionController::Base
    before_action :authenticate_schema

    protected
    def authenticate_request!
      unless service_id_in_token?
        render json: { errors: ['Not Authenticated'] }, status: :unauthorized
        return
      end
      @authenticated_service = Service.find(auth_token[:service_id])
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
      @current_service ||= Service.find_by_subdomain(params[:current_subdomain])
    end

    def authenticate_schema
      if current_service.nil?
        render nothing: true, status: :not_found
        return false
      end
      unless @current_service.is_activated?
        head :forbidden
        return false
      end
    end
  end
end
