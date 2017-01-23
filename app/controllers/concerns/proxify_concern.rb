module ProxifyConcern
  extend ActiveSupport::Concern

  included do
    before_action :proxy_initialize, only: [:process_request]
  end

  class ProxyError < StandardError
    attr_reader :code
    attr_reader :body

    def initialize(data = {})
      data[:code] ||= 310
      @data = data
    end

    def code
      @data[:code]
    end

    def body
      @data[:body]
    end
  end

  class ProxyInitializationError < ProxyError
  end

  class ProxyAuthenticationError < ProxyError
  end

  class ProxyRequestError < ProxyError
  end

  def proxy_initialize
    raise ProxyInitializationError if current_proxy.nil?
    raise ProxyInitializationError if current_route.nil?
    @current_proxy_access_token = nil
    @current_proxy_send_request = nil
    @current_proxy_uri_object = nil
    @current_proxy_parameter = current_proxy.proxy_parameter
    @current_proxy_cache_token = current_proxy.cache_token
  end

  def proxy_request
    proxy_authenticate if @current_proxy_parameter.authentication_mode != 'null'
    proxy_prepare_request "#{current_route.uri}#{"/#{params[:follow_url]}" if @current_proxy_parameter.follow_url && params[:follow_url].present?}", request.query_parameters
    proxy_send_request
  end

  def proxy_prepare_request(uri, query = nil)
    @current_proxy_uri_object = URI.parse uri
    @current_proxy_uri_object.query = URI.encode_www_form(query) unless query.nil?
    @current_proxy_send_request = Net::HTTP::Get.new @current_proxy_uri_object
    case @current_proxy_parameter.authentication_mode
      when 'oauth2' then @current_proxy_send_request.add_field 'Authorization', "Bearer #{current_proxy_access_token}" if current_proxy_access_token.present?
    end
  end

  def proxy_authenticate_after_unauthorized
    cache_del @current_proxy_cache_token
    proxy_authenticate @current_proxy_parameter
  end

  def proxy_authenticate
    if current_proxy_access_token.nil?
      if @current_proxy_parameter.authentication_mode == 'oauth2'
        uri = URI.parse current_proxy.authentication_uri
        req = Net::HTTP::Post.new uri
        req.content_type = 'application/x-www-form-urlencoded'
        req.set_form_data({realm: @current_proxy_parameter.realm,
                           grant_type: @current_proxy_parameter.grant_type || 'client_credentials',
                           client_id: @current_proxy_parameter.client_id,
                           client_secret: @current_proxy_parameter.client_secret,
                           scope: @current_proxy_parameter.scope})

        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = @current_proxy_parameter.protocol == 'https'
        res = http.request req

        case res
          when Net::HTTPOK, Net::HTTPCreated   then set_current_proxy_access_token JSON.parse(res.body)['access_token']
          else
            raise ProxyAuthenticationError, {code: res.code, body: res.body}
        end
      end
    end
  end

  def proxy_send_request(limit = nil)
    limit ||= @current_proxy_parameter.follow_redirection

    http = Net::HTTP.new @current_proxy_uri_object.host, @current_proxy_uri_object.port
    http.use_ssl = @current_proxy_uri_object.scheme == 'https'
    res = http.request @current_proxy_send_request

    case res
      when Net::HTTPUnauthorized  then proxy_authenticate_after_unauthorized; proxy_send_request(limit - 1)
      when Net::HTTPRedirection   then limit -= 1; if limit == -1 then raise ProxyRequestError else proxy_prepare_request(res['location']); proxy_send_request(limit) end
      when Net::HTTPSuccess       then res
      else
        raise ProxyRequestError, {code: res.code, body: res.body}
    end
  end

  def current_proxy_access_token
    @current_proxy_access_token ||= cache_hget(@current_proxy_cache_token, :access_token)
  end

  def set_current_proxy_access_token(access_token)
    @current_proxy_access_token = access_token
    cache_hmset @current_proxy_cache_token, {access_token: access_token}
    cache_expire @current_proxy_cache_token, 500
  end
end
