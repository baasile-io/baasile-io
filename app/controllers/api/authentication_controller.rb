module Api
  class AuthenticationController < ApiController
    skip_before_action :authenticate_schema

    def authenticate
      unless params[:scope].present?
        raise AuthMissingScopeError
      end
      @scope = params.fetch(:scope, '').split.sort! {|a,b| a.downcase <=> b.downcase}.join(' ')
      return authenticate_by_refresh_token if params[:grant_type] == 'refresh_token'
      unless params[:client_id].present?
        raise AuthMissingClientIdError
      end
      @service = Service.find_by_client_id(params[:client_id])
      if @service.nil?
        raise AuthInvalidClientIdError
      elsif params[:client_secret].blank?
        raise AuthMissingClientSecretError
      elsif @service.client_secret != params[:client_secret]
        raise AuthBadCredentialsError
      end
      check_service_activation
    end

    def authenticate_by_refresh_token
      unless params[:refresh_token].present?
        raise AuthMissingRefreshTokenError
      end
      @refresh_token = RefreshToken.includes(:service).find_by(value: params[:refresh_token])
      if @refresh_token.nil?
        raise AuthInvalidRefreshTokenError
      elsif @refresh_token.expires_at < DateTime.now
        raise AuthExpiredRefreshTokenError
      end
      @service = @refresh_token.service
      check_service_activation
    end

    def check_service_activation
      unless @service.is_activated?
        raise AuthInactiveClientError
      end
      render json: payload
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
