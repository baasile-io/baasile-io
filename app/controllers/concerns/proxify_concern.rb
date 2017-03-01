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
      @data[:code].to_i
    end

    def body
      @data[:body]
    end

    def req
      @data[:req]
    end

    def uri
      @data[:uri]
    end
  end

  class ProxyInitializationError < ProxyError
  end

  class ProxyAuthenticationError < ProxyError
  end

  class ProxyRedirectionError < ProxyError
  end

  class ProxyRequestError < ProxyError
  end

  def proxy_initialize
    raise ProxyInitializationError if current_proxy.nil?
    raise ProxyInitializationError if current_route.nil?
    @current_proxy_access_token = nil
    @current_proxy_send_request = nil
    @current_proxy_uri_object = nil
    @current_proxy_parameter = current_proxy.proxy_parameter_test #TODO: production when contract is activated
    @current_route_uri = current_route.uri_test #TODO: production when contract is activated
    @current_proxy_cache_token = current_proxy.cache_token
  end

  def proxy_request
    proxy_authenticate if @current_proxy_parameter.authorization_mode != 'null'
    proxy_prepare_request "#{@current_route_uri}#{"/#{params[:follow_url]}" if @current_proxy_parameter.follow_url && params[:follow_url].present?}", request.GET
    proxy_send_request
  end

  def proxy_prepare_request(uri, query = nil)
    @current_proxy_uri_object = URI.parse uri
    @current_proxy_uri_object.query = URI.encode_www_form(query) unless query.nil?

    method_symbol = request.method_symbol
    request_obj = case method_symbol
                    when :get then Net::HTTP::Get
                    when :post then Net::HTTP::Post
                    when :head then Net::HTTP::Head
                    when :put then Net::HTTP::Put
                    when :delete then Net::HTTP::Delete
                  end
    @current_proxy_send_request = request_obj.send(:new, @current_proxy_uri_object)

    if request.content_type
      case @current_proxy_send_request.content_type = request.content_type
        when 'application/x-www-form-urlencoded'
          @current_proxy_send_request.set_form_data(request.POST) if request.method_symbol == :post
        else
          @current_proxy_send_request.body = request.raw_post
      end
    end

    #headers = request.headers.env.select { |k, _| k =~ /^HTTP_(USER|ACCEPT)/ }
    #headers.each do |header|
    #  name = header[0].sub(/^HTTP_/, '').gsub(/_/, '-')
    #  @current_proxy_send_request[name] = header[1]
    #end

    @current_proxy_send_request[I18n.t('config.headers.proxy_callback')] = "#{current_host}/api/v1/#{current_service.subdomain}/proxies/#{current_proxy.id}/routes/#{current_route.id}/request"

    case @current_proxy_parameter.authorization_mode
      when 'oauth2' then @current_proxy_send_request.add_field 'Authorization', "Bearer #{current_proxy_access_token}" if current_proxy_access_token.present?
    end
  end

  def proxy_authenticate_after_unauthorized
    cache_del @current_proxy_cache_token
    proxy_authenticate
  end

  def proxy_authenticate
    if current_proxy_access_token.nil?
      if @current_proxy_parameter.authorization_mode == 'oauth2'
        uri = URI.parse current_proxy.authorization_uri
        new_query_ar = URI.decode_www_form(uri.query || '')
        new_query_ar << ["realm", @current_proxy_parameter.realm] if @current_proxy_parameter.realm.present?
        uri.query = URI.encode_www_form(new_query_ar)
        req = Net::HTTP::Post.new uri
        req.content_type = 'application/x-www-form-urlencoded'
        params = {
          client_id: @current_proxy_parameter.identifier.client_id,
          client_secret: @current_proxy_parameter.identifier.decrypt_secret
        }
        params[:grant_type] = @current_proxy_parameter.grant_type if @current_proxy_parameter.grant_type.present?
        params[:scope] = @current_proxy_parameter.scope.strip if @current_proxy_parameter.scope.present?
        req.set_form_data(params)

        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = @current_proxy_parameter.protocol == 'https'
        res = http.request req

        case res
          when Net::HTTPOK, Net::HTTPCreated   then set_current_proxy_access_token JSON.parse(res.body)['access_token']
          else
            raise ProxyAuthenticationError, {uri: uri, req: req, code: res.code, body: res.body}
        end
      end
    end
  end

  def proxy_send_request(limit = nil)
    limit ||= @current_proxy_parameter.follow_redirection

    http = Net::HTTP.new(@current_proxy_uri_object.host, @current_proxy_uri_object.port)
    http.use_ssl = @current_proxy_uri_object.scheme == 'https'

    Rails.logger.info "Proxy Request: #{@current_proxy_uri_object}"
    res = http.request @current_proxy_send_request

    case res
      when Net::HTTPUnauthorized  then proxy_authenticate_after_unauthorized; proxy_send_request(limit - 1)
      when Net::HTTPRedirection   then limit -= 1; if limit == -1 then raise(ProxyRedirectionError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, code: res.code, body: res.body}) else proxy_prepare_request(res['location']); proxy_send_request(limit) end
      when Net::HTTPSuccess       then res
      else
        raise ProxyRequestError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, code: res.code, body: res.body}
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
