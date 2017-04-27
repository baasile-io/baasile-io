module Api
  class AuthenticationController < ApiController
    skip_before_action :authenticate_schema

    def authenticate
      @scope = params.fetch(:scope, '').split.sort! {|a,b| a.downcase <=> b.downcase}.join(' ')
      return authenticate_by_refresh_token if params[:grant_type] == 'refresh_token'
      if params[:client_id].present?
        @service = Service.find_by_client_id(params[:client_id])
        if @service.nil?
          title = 'Invalid client_id'
        elsif params[:client_secret].blank?
          title = 'Missing client_secret'
        elsif @service.client_secret == params[:client_secret]
          return check_service_activation
        end
      else
        title = 'Missing client_id'
      end
      status = 400
      title ||= 'Client authentication failed'
      render status: status, json: {
        errors: [{
          status: status,
          title: title
        }]
      }
    end

    def authenticate_by_refresh_token
      unless params[:refresh_token].present?
        title = "Missing refresh_token"
      else
        @refresh_token = RefreshToken.includes(:service).find_by(value: params[:refresh_token])
        if @refresh_token.nil?
          title = 'Invalid refresh_token'
        else
          if @refresh_token.expires_at >= DateTime.now
            @service = @refresh_token.service
            return check_service_activation
          else
            status = 401
            title = 'Token has expired'
          end
        end
      end
      status ||= 400
      title ||= 'Client authentication failed'
      render status: status, json: {
        errors: [{
          status: status,
          title: title
        }]
      }
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
