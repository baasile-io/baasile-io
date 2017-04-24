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
        raise MissingAuthorizationHeader unless http_token.present?
        auth_token = JsonWebToken.decode(http_token)
        raise ServiceIdInTokenError unless auth_token[:service_id].to_i
        env[:authenticated_service] = Service.find(auth_token[:service_id])
        env[:authenticated_scope] = auth_token[:scope] || ''
      rescue OptionsRequest
        allowed_headers = env.fetch('HTTP_ACCESS_CONTROL_REQUEST_HEADERS', 'Origin, Authorization, Accept, Content-Type')
        return [200, {'Content-Type' => 'plain/text',
                      'Access-Control-Allow-Origin' => '*',
                      'Access-Control-Allow-Headers' => "#{allowed_headers}, Authorization",
                      'Access-Control-Allow-Methods' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD',
                      'Access-Control-Request-Method' => 'POST, PUT, DELETE, GET, OPTIONS, PATCH, HEAD'}, ['']]
      rescue MissingAuthorizationHeader
        return [400, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 400,
                                                                    title: 'Missing authorization header.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      rescue JWT::ExpiredSignature
        return [403, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 403,
                                                                    title: 'This authorization token has expired.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      rescue JWT::VerificationError, JWT::DecodeError
        return [403, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 403,
                                                                    title: 'Signature verification failed.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      rescue JWT::DecodeError
        return [403, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 403,
                                                                    title: 'Failed to decode authorization token.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      rescue ActiveRecord::RecordNotFound
        return [403, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 403,
                                                                    title: 'Client ID not found in database.'
                                                                  }
                                                                ]
                                                              }.to_json]]
      rescue
        return [403, {'Content-Type' => 'application/json'}, [{
                                                                errors: [
                                                                  {
                                                                    status: 403,
                                                                    title: 'Authorization failed due to an invalid token.'
                                                                  }
                                                                ]
                                                              }.to_json]]
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
