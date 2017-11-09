module ProxifyConcern
  extend ActiveSupport::Concern

  def proxy_initialize
    raise Api::ProxyInitializationError if current_proxy.nil?
    raise Api::ProxyInitializationError if current_route.nil?
    @current_proxy_access_token = nil
    @current_proxy_send_request = nil
    @current_proxy_uri_object = nil
    @current_proxy_parameter = current_proxy.send("proxy_parameter#{'_test' if @use_test_settings}")
    @current_route_uri = current_route.send("uri#{'_test' if @use_test_settings}")
    @current_proxy_cache_token = "#{@cache_token_prefix}#{current_proxy.send("cache_token#{'_test' if @use_test_settings}")}"
  end

  def proxy_request
    proxy_authenticate if @current_proxy_parameter.authorization_mode != 'null' && @use_authorization != false
    proxy_prepare_request "#{@current_route_uri}#{"/#{params[:follow_url]}" if @current_proxy_parameter.follow_url && params[:follow_url].present?}", build_get_params
    proxy_send_request
  rescue SocketError => e
    raise Api::ProxySocketError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, message: e.message}
  rescue OpenSSL::SSL::SSLError => e
    raise Api::ProxySSLError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, message: e.message}
  rescue EOFError => e
    raise Api::ProxyEOFError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, message: e.message}
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise Api::ProxyTimeoutError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, message: e.message}
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    raise Api::ProxyInvalidSecretSignatureError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, message: e.message}
  end

  def build_headers
    @request_headers.each do |key, value|
      @current_proxy_send_request[key] = value
    end

    current_route.query_parameters.by_type(:header).each do |query_parameter|
      @current_proxy_send_request[query_parameter.name] = @request_headers[query_parameter.name.upcase.gsub(/_/, '-')]
      transform_param(query_parameter, @current_proxy_send_request, query_parameter.name)
    end
  end

  def build_get_params
    return nil if @request_get.nil?

    parameters = @request_get.deep_dup

    current_route.query_parameters.by_type(:get).each do |query_parameter|
      parse_get_param(
        query_parameter,
        Rack::Utils.parse_nested_query(query_parameter.name),
        parameters
      )
    end

    parameters
  end

  def parse_get_param(query_parameter, query_parameter_hash, parameters)
    key, value = query_parameter_hash.first

    if value.is_a?(Hash)
      parameters[key] ||= {}
      parse_get_param(query_parameter, value, parameters[key])
    else
      transform_param(query_parameter, parameters, key)
    end
  end

  def transform_param(query_parameter, destination, key)
    case query_parameter.mode.to_sym
      when :forbidden
        if query_parameter.default_value.present?
          destination[key] = query_parameter.default_value
        else
          destination.delete(key)
        end
      when :optional
        if destination[key].nil? && query_parameter.default_value.present?
          destination[key] = query_parameter.default_value
        end
      when :mandatory
        if destination[key].nil?
          raise Api::ProxyMissingMandatoryQueryParameterError, {message: "Missing parameter: #{query_parameter.query_parameter_type.upcase} #{query_parameter.name}"}
        end
    end
  end

  def proxy_prepare_request(uri, query = nil)
    @current_proxy_uri_object = URI.parse uri
    @current_proxy_uri_object.query = URI.encode_www_form(query) unless query.nil?

    request_obj = case @request_method
                    when 'GET' then Net::HTTP::Get
                    when 'POST' then Net::HTTP::Post
                    when 'HEAD' then Net::HTTP::Head
                    when 'PUT' then Net::HTTP::Put
                    when 'DELETE' then Net::HTTP::Delete
                  end
    @current_proxy_send_request = request_obj.send(:new, @current_proxy_uri_object)

    if @request_content_type
      @current_proxy_send_request.body = @request_body
    end

    build_headers

    @current_proxy_send_request[Appconfig.get(:api_client_token_id_name)] = authenticated_service.client_id
    @current_proxy_send_request[Appconfig.get(:api_proxy_callback_uri_name)] = "#{current_host}#{current_route.local_url('v1')}"
    @current_proxy_send_request[Appconfig.get(:api_measure_token_name)] = current_measure_token.value unless current_measure_token.nil?

    case @current_proxy_parameter.authorization_mode
      when 'oauth2' then @current_proxy_send_request.add_field 'Authorization', "Bearer #{current_proxy_access_token}" if current_proxy_access_token.present?
    end

    unless current_route.allowed_methods.include?(@request_method)
      raise Api::ProxyMethodNotAllowedError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request}
    end
  end

  def proxy_authenticate_after_unauthorized
    cache_del @current_proxy_cache_token
    proxy_authenticate
  end

  def proxy_authenticate
    if current_proxy_access_token.nil?
      if @current_proxy_parameter.authorization_mode == 'oauth2'
        uri = URI.parse current_proxy.send("authorization_uri#{'_test' if @use_test_settings}")
        new_query_ar = URI.decode_www_form(uri.query || '')
        new_query_ar << ["realm", @current_proxy_parameter.realm] if @current_proxy_parameter.realm.present?
        uri.query = URI.encode_www_form(new_query_ar)
        req = Net::HTTP::Post.new uri
        req.content_type = 'application/x-www-form-urlencoded'

        auth_params = {}.tap do |p|
          p[:client_id] = @current_proxy_parameter.identifier.client_id
          p[:client_secret] = @current_proxy_parameter.identifier.decrypt_secret

          if @current_proxy_parameter.grant_type.present?
            p[:grant_type] = @current_proxy_parameter.grant_type
          end

          if @current_proxy_parameter.scope.present?
            p[:scope] = @current_proxy_parameter.scope.strip
          end
        end

        req.set_form_data(auth_params)

        http = Net::HTTP.new uri.host, uri.port
        http.read_timeout = Appconfig.get(:api_read_timeout)
        http.use_ssl = uri.scheme == 'https'

        Rails.logger.info "Proxy Auth Request: #{uri}"
        res = http.request req

        case res
          when Net::HTTPOK, Net::HTTPCreated
            begin
              access_token = JSON.parse(res.body)['access_token']
              unless access_token.present?
                raise Api::AuthAccessTokenNotFoundError, {uri: uri, req: req, res: res}
              end
              set_current_proxy_access_token access_token
            rescue JSON::ParserError
              raise Api::AuthJSONParseErrorError, {uri: uri, req: req, res: res}
            end
          when Net::HTTPBadRequest
            raise Api::AuthBadRequestError, {uri: uri, req: req, res: res}
          else
            raise Api::ProxyAuthenticationError, {uri: uri, req: req, res: res}
        end
      end
    end
  end

  def proxy_send_request(limit = nil, limit_unauthorized = 2)
    limit ||= @current_proxy_parameter.follow_redirection

    http = Net::HTTP.new(@current_proxy_uri_object.host, @current_proxy_uri_object.port)
    http.read_timeout = Appconfig.get(:api_read_timeout)
    http.use_ssl = @current_proxy_uri_object.scheme == 'https'

    Rails.logger.info "Proxy Request: #{limit} #{@current_proxy_uri_object}"
    res = http.request @current_proxy_send_request

    case res
      when Net::HTTPUnauthorized
        if @current_proxy_parameter.authorization_mode != 'null' && limit > -1
          proxy_authenticate_after_unauthorized
          proxy_send_request(limit, limit_unauthorized - 1)
        else
          raise Api::ProxyUnauthorizedError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res}
        end
      when Net::HTTPRedirection
        if limit <= -1
          raise(Api::ProxyRedirectionError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res})
        else
          proxy_prepare_request(res['location'])
          proxy_send_request(limit - 1, limit_unauthorized)
        end
      when Net::HTTPNotFound
        raise Api::ProxyNotFoundError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res}
      when Net::HTTPMethodNotAllowed
        raise Api::ProxyMethodNotAllowedError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res}
      when Net::HTTPBadRequest
        raise Api::ProxyBadRequestError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res}
      when Net::HTTPSuccess
        res
      else
        raise Api::ProxyRequestError, {uri: @current_proxy_uri_object, req: @current_proxy_send_request, res: res}
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
