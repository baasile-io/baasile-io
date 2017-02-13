module Api
  class ApiController < ActionController::Base
    before_action :authenticate_schema

    private

    def current_service
      @current_service ||= Service.find_by_subdomain(params[:current_subdomain])
    end

    def current_host
      "#{request.protocol}#{request.host_with_port}"
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

    def authenticated_service
      @authenticated_service ||= request.env[:authenticated_service]
    end

    def authenticated_scope
      @authenticated_scope ||= request.env[:authenticated_scope].split
    end
  end
end
