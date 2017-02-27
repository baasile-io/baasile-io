class ApiAuthMiddleware
  class ServiceIdInTokenError < StandardError; end
  class MissingAuthorizationHeader < StandardError; end

  def initialize app
    @app = app
  end

  def call(env)
    if restricted_path? ::Rack::Request.new(env).path
      begin
        http_token = env.fetch('HTTP_AUTHORIZATION', '').split(' ').last
        raise MissingAuthorizationHeader unless http_token.present?
        auth_token = JsonWebToken.decode(http_token)
        raise ServiceIdInTokenError unless auth_token[:service_id].to_i
        env[:authenticated_service] = Service.find(auth_token[:service_id])
        env[:authenticated_scope] = auth_token[:scope]
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
