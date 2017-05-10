module Api
  class ProxyError < StandardError
    attr_reader :code
    attr_reader :req
    attr_reader :res
    attr_reader :uri
    attr_reader :message

    def initialize(data = {})
      data[:code] ||= 502
      @data = data
    end

    def code
      @data[:code].to_i
    end

    def req
      @data[:req]
    end

    def res
      @data[:res]
    end

    def uri
      @data[:uri]
    end

    def message
      @data[:message]
    end
  end

  class ProxySSLError < ProxyError
    def code
      601
    end
  end

  class ProxySocketError < ProxyError
    def code
      602
    end
  end

  class ProxyRedirectionError < ProxyError
    def code
      603
    end
  end

  class ProxyAuthenticationError < ProxyError
    def code
      604
    end
  end

  class ProxyInitializationError < ProxyError
    def code
      605
    end
  end

  class ProxyMissingMandatoryQueryParameterError < ProxyError
    def code
      606
    end
  end

  class ProxyRequestError < ProxyError
    def code
      607
    end
  end

  class ProxyNotFoundError < ProxyError
    def code
      608
    end
  end

  class ProxyEOFError < ProxyError
    def code
      609
    end
  end

  class ProxyTimeoutError < ProxyError
    def code
      610
    end
  end

  class ProxyMethodNotAllowedError < ProxyError
    def code
      611
    end
  end

  class ProxyInvalidSecretSignatureError < ProxyError
    def code
      612
    end
  end

  class ProxyBadRequestError < ProxyError
    def code
      613
    end
  end

  class ProxyUnauthorizedError < ProxyError
    def code
      614
    end
  end

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
      if !(authenticated_scope.include?(current_service.subdomain) || current_service.id == authenticated_service.id) && !(current_service.parent && (authenticated_scope.include?(current_service.parent.subdomain) || current_service.parent.id == authenticated_service.id))
        return render status: 403, json: {
          errors: [{
                     status: 403,
                     title: "Unknown/invalid scope(s): #{authenticated_scope.inspect}. Required scope: \"#{current_service.subdomain}\""
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
