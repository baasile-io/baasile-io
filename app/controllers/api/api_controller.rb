module Api
  class ApiController < ActionController::Base
    before_action :authenticate_schema, except: :not_found

    def not_found
      raise BaseNotFoundError
    end

    private

    def current_service
      @current_service ||= Service.find_by_subdomain(params[:current_subdomain])
    end

    def current_host
      "#{request.protocol}#{request.host_with_port}"
    end

    def authenticate_schema
      if current_service.nil?
        raise BaseNotFoundError
      elsif !current_service.is_activated?
        raise OtherNotActiveSupplierError
      end
      if !(authenticated_scope.include?(current_service.subdomain) || current_service.id == authenticated_service.id) && !(current_service.parent && (authenticated_scope.include?(current_service.parent.subdomain) || current_service.parent.id == authenticated_service.id))
        raise AuthInvalidScopeError
      end
    end

    def authenticated_service
      @authenticated_service ||= request.env[:authenticated_service]
    end

    def authenticated_scope
      @authenticated_scope ||= (request.env[:authenticated_scope] || '').split
    end
  end
end
