module Api
  class AuthenticationController < ApiController
    skip_before_action :authenticate_schema

    def authenticate
      @scope = params.fetch(:scope, '').split.sort! {|a,b| a.downcase <=> b.downcase}.join(' ')
      return authenticate_by_refresh_token if params[:grant_type] == 'refresh_token'
      if params[:client_id].present?
        @service = Service.find_by_client_id(params[:client_id])
        if !@service.nil? && @service.client_secret == params[:client_secret]
          return check_service_activation
        end
      end
      status = 400
      title = 'Client authentication failed'
      render status: status, json: {
        errors: [{
          status: status,
          title: title
        }]
      }
    end

    def authenticate_by_refresh_token
      @refresh_token = RefreshToken.includes(:service).find_by(value: params[:refresh_token])
      if !@refresh_token.nil?
        if @refresh_token.expires_at >= DateTime.now
          @service = @refresh_token.service
          check_service_activation
        else
          status = 401
          title = 'Token has expired'
          render status: status, json: {
            errors: [{
              status: status,
              title: title
            }]
          }
        end
      else
        status = 400
        title = 'Client authentication failed'
        render status: status, json: {
          errors: [{
            status: status,
            title: title
          }]
        }
      end
    end

    def check_service_activation
      if @service.is_activated?
        render json: payload
      else
        status = 403
        title = 'Client is not activated'
        render status: status, json: {
          errors: [{
                     status: status,
                     title: title
                   }]
        }
      end
    end

    def check_token
      authenticate_request!
      render json: {status: 'ok'}
    end

    private

    def payload
      @refresh_token ||= RefreshToken.find_or_initialize_by(service: @service, scope: @scope)
      if @refresh_token.save
        expires_in = Appconfig.get(:api_access_token_duration) * 60
        exp = Time.now.to_i + expires_in
        auth_token = JsonWebToken.encode({service_id: @service.id, scope: @refresh_token.scope, exp: exp})
        {
          token_type: 'Bearer',
          expires_in: expires_in,
          auth_token: auth_token,
          access_token: auth_token,
          refresh_token: @refresh_token.value,
          scope: @refresh_token.scope
        }
      else
        raise StandardError
      end
    end
  end
end
