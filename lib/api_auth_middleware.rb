class ApiAuthMiddleware
  class OptionsRequest < StandardError; end
  class ServiceIdInTokenError < StandardError; end
  class MissingAuthorizationHeader < StandardError; end

  def initialize app
    @app = app
  end

  def call(env)
    req = ::Rack::Request.new(env)
    if restricted_path? req.path
      begin
        raise OptionsRequest if env.fetch('REQUEST_METHOD', '') == 'OPTIONS'
        http_token = env.fetch('HTTP_AUTHORIZATION', '').split(' ').last
        raise Api::AuthMissingAuthorizationHeader unless http_token.present?
        auth_token = JsonWebToken.decode(http_token)
        raise ServiceIdInTokenError unless auth_token[:service_id].to_i
        env[:authenticated_service] = Service.find(auth_token[:service_id])
        env[:authenticated_scope] = auth_token[:scope] || ''
        unless env[:authenticated_service].is_activated?
          raise Api::AuthInactiveClientError
        end
      rescue OptionsRequest
        allowed_headers = env.fetch('HTTP_ACCESS_CONTROL_REQUEST_HEADERS', 'Origin, Authorization, Accept, Content-Type')
        return [200, {'Content-Type' => 'plain/text',
                      'Access-Control-Allow-Origin' => '*',
                      'Access-Control-Allow-Headers' => "#{allowed_headers}, Authorization",
                      'Access-Control-Allow-Methods' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD',
                      'Access-Control-Request-Method' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD'}, ['']]
      rescue JWT::ExpiredSignature
        raise Api::AuthExpiredAccessTokenError
      rescue JWT::VerificationError, JWT::DecodeError
        raise Api::AuthInvalidAccessTokenError
      rescue ActiveRecord::RecordNotFound
        raise Api::AuthClientNotFoundError
      end
    end
    status, headers, response = @app.call(env)
    [status, headers, response]
  end

  private

  def restricted_path?(path)
    !path.match(/\A\/api\/oauth\//) && path.match(/\A\/api\//)
  end
end
