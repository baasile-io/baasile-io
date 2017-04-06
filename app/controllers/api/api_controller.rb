module Api
  class ApiController < ActionController::Base
    before_action :authenticate_schema, except: :not_found

    def not_found
      return render status: 404, json: {
        errors: [{
                   status: 404,
                   title: 'Route not found'
                 }]
      }
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
        return render status: 404, json: {
          errors: [{
                     status: 404,
                     title: 'Service not found'
                   }]
        }
      end
      unless current_service.is_activated?
        return render status: 403, json: {
          errors: [{
                     status: 403,
                     title: 'Inactive service'
                   }]
        }
      end
      if !current_service.public && current_service.id != authenticated_service.id
        return render status: 403, json: {
          errors: [{
                     status: 403,
                     title: 'Forbidden private service'
                   }]
        }
      end
      unless authenticated_scope.include?(current_service.subdomain)
        return render status: 400, json: {
          errors: [{
                     status: 400,
                     title: "Unknown/invalid scope(s): #{authenticated_scope.inspect}. Required scope: \"#{current_service.subdomain}\"."
                   }]
        }
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
