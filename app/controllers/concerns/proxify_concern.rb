module ProxifyConcern
  extend ActiveSupport::Concern

  included do
    before_action :proxy_initialize
  end

  def proxy_initialize
    @proxy_access_token = nil
  end

  def proxy_authenticate(proxy_parameter)
    @proxy_access_token = cache_hget(proxy_parameter.redis_token, :access_token)
    Rails.logger.info "access_token: #{@proxy_access_token}"
    return if @proxy_access_token.present?
    if proxy_parameter.authentication_mode == 'oauth2'
      uri_str = "#{proxy_parameter.protocol}://#{proxy_parameter.hostname}:#{proxy_parameter.port}#{proxy_parameter.authentication_url}"
      uri = URI.parse uri_str
      req = Net::HTTP::Post.new uri
      req.content_type = 'application/x-www-form-urlencoded'
      req.set_form_data({realm: 'developpeur',
                         grant_type: 'client_credentials',
                         client_id: proxy_parameter.client_id,
                         client_secret: proxy_parameter.client_secret})
      res = nil
      Net::HTTP.start(uri.host, uri.port, use_ssl: proxy_parameter.protocol == 'https') do |http|
        res = http.request req # Net::HTTPResponse object
      end

      case res
        when Net::HTTPSuccess
        then
          @proxy_access_token = JSON.parse(res.body)['access_token']
          cache_hmset proxy_parameter.redis_token, {access_token: @proxy_access_token}
          cache_expire proxy_parameter.redis_token, 500
          @proxy_access_token
        else
          'error'
      end
    end
  end

  def proxy_request(uri_str, limit = 10)
    uri = URI.parse uri_str
    req = Net::HTTP::Get.new uri

    req.add_field 'Authorization', "Bearer #{@proxy_access_token}" if @proxy_access_token.present?

    res = nil
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      res = http.request req
    end

    case res
      when Net::HTTPUnauthorized  then cache_expire(@proxy.proxy_parameter.redis_token, -1); proxy_authenticate(@proxy.proxy_parameter); proxy_request(uri_str, limit - 1)
      when Net::HTTPRedirection   then proxy_request(res['location'], limit - 1)
      else
        res
    end
  end
end
