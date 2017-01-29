class ApiAuthMiddleware
  class ServiceIdInTokenError < StandardError; end

  def initialize app
    @app = app
  end

  def call(env)
    @http_token = env.fetch('HTTP_AUTHORIZATION', '').split(' ').last
    if restricted_path? ::Rack::Request.new(env).path
      begin
        service = authenticate
      rescue JWT::ExpiredSignature
        return [403, {}, ['']]
      rescue JWT::VerificationError, JWT::DecodeError
        return [403, {}, ['']]
      rescue
        return [403, {}, ['']]
      end
    end
    status, headers, response = @app.call(env)
    [status, headers, response]
  end

  private

  def authenticate
    unless service_id_in_token?
      raise ServiceIdInTokenError
    end
    Service.find(auth_token[:service_id])
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(@http_token)
  end

  def service_id_in_token?
    @http_token.present? && auth_token && auth_token[:service_id].to_i
  end

  def restricted_path?(path)
    path != '/api/oauth/token' && path.match(/\A\/api\//)
  end
end
