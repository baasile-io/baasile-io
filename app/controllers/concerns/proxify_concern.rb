module ProxifyConcern
  extend ActiveSupport::Concern

  included do
    before_action :proxy_initialize
  end

  class ProxyInitializationError < StandardError
  end

  class ProxyAuthenticationError < StandardError
  end

  def proxy_initialize
    raise ProxyInitializationError if current_proxy.nil?
    raise ProxyInitializationError if current_route.nil?
    @current_proxy_access_token = nil
    @current_proxy_request = nil
    @current_proxy_uri_object = nil
  end

  def proxy_process
    if current_proxy.proxy_parameter.authentication_mode != 'null'
      proxy_authenticate
      Rails.logger.info "current_proxy_access_token: #{current_proxy_access_token}"
    end

    uri = "#{current_route.uri}?#{URI.encode_www_form(request.query_parameters)}"
    proxy_prepare_request uri
    proxy_request
  end

  def proxy_prepare_request(uri)
    @current_proxy_uri_object = URI.parse uri
    @current_proxy_request = Net::HTTP::Get.new @current_proxy_uri_object
    case current_proxy.proxy_parameter.authentication_mode
      when 'oauth2' then @current_proxy_request.add_field 'Authorization', "Bearer #{current_proxy_access_token}" if current_proxy_access_token.present?
    end
  end

  def proxy_authenticate_after_unauthorized
    cache_del current_proxy.proxy_parameter.redis_token
    proxy_authenticate current_proxy.proxy_parameter
  end

  def proxy_authenticate
    if current_proxy_access_token.nil?
      if current_proxy.proxy_parameter.authentication_mode == 'oauth2'
        uri = URI.parse current_proxy.authentication_uri
        req = Net::HTTP::Post.new uri
        req.content_type = 'application/x-www-form-urlencoded'
        req.set_form_data({realm: current_proxy.proxy_parameter.realm,
                           grant_type: current_proxy.proxy_parameter.grant_type,
                           client_id: current_proxy.proxy_parameter.client_id,
                           client_secret: current_proxy.proxy_parameter.client_secret})
        res = nil
        Net::HTTP.start(uri.host, uri.port, use_ssl: current_proxy.proxy_parameter.protocol == 'https') do |http|
          res = http.request req
        end

        case res
          when Net::HTTPSuccess   then set_current_proxy_access_token JSON.parse(res.body)['access_token']
          else
            raise ProxyAuthenticationError
        end
      end
    end
  end

  def proxy_request(limit = 10)
    res = nil
    Net::HTTP.start(@current_proxy_uri_object.host, @current_proxy_uri_object.port, :use_ssl => @current_proxy_uri_object.scheme == 'https') do |http|
      res = http.request @current_proxy_request
    end

    case res
      when Net::HTTPUnauthorized  then proxy_authenticate_after_unauthorized; proxy_request(limit - 1)
      when Net::HTTPRedirection   then proxy_prepare_request(res['location']); proxy_request(limit - 1)
      else
        res
    end
  end

  def current_proxy_access_token
    @current_proxy_access_token ||= cache_hget(current_proxy.proxy_parameter.redis_token, :access_token)
  end

  def set_current_proxy_access_token(access_token)
    @current_proxy_access_token = access_token
    cache_hmset current_proxy.proxy_parameter.redis_token, {access_token: access_token}
    cache_expire current_proxy.proxy_parameter.redis_token, 500
  end
end
