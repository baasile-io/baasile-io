module Api
  class ProxiesController < ApiController
    before_action :authenticate_request!
    before_action :load_proxy_and_authorize

    def show

      proxy_parameter = @proxy.proxy_parameter

      @access_token = nil

      #return render plain:
      if proxy_parameter.authentication_mode != 'null'

        if proxy_parameter.authentication_mode == 'oauth2'
          uri_str = "#{proxy_parameter.protocol}://#{proxy_parameter.hostname}:#{proxy_parameter.port}#{proxy_parameter.authentication_url}"

          uri = URI.parse uri_str
          req = Net::HTTP::Post.new uri
          req.content_type = 'application/x-www-form-urlencoded'
          req.set_form_data({realm: 'developpeur',
                                 grant_type: 'client_credentials',
                                 client_id: proxy_parameter.client_id,
                                 client_secret: proxy_parameter.client_secret})

          Net::HTTP.start(uri.host, uri.port, use_ssl: proxy_parameter.protocol == 'https') do |http|


            #return render plain: req.body

            #http.ssl_version = :SSLv2

            res = http.request req # Net::HTTPResponse object

            @access_token = JSON.parse(res.body)['access_token']
            #return render plain: @access_token.inspect
            #render plain: res.body
          end
        end

      end

      proxy_parameter.hostname = 'api.emploi-store.fr'
      uri_str = "#{proxy_parameter.protocol}://#{proxy_parameter.hostname}:#{proxy_parameter.port}/#{params[:url]}/?#{URI.encode_www_form(request.query_parameters)}"

      #Rails.logger.error uri
      #response = HTTParty.get(uri, {format: :html, verify: false})

      #return render plain: uri_str

      res = request_server uri_str, 10

      return render plain: res.body

      #req.add_field "Accept", "text/html"
      #req.add_field "User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
      #res = Net::HTTP.start url.host, url.port do |http|
      #  http.request(req)
      #end

      #limit = 10
      #case res
      #  when Net::HTTPSuccess     then res
      #  when Net::HTTPRedirection then fetch(res['location'], limit - 1)
      #  #else
      #    #res.error!
      #end
    end

    def request_server(uri_str, limit = 10)
      uri = URI.parse uri_str
      req = Net::HTTP::Get.new uri
      req.add_field 'Authorization', "Bearer #{@access_token}"
      #http.ssl_version = :SSLv2

      res = nil
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https') do |http|

        res = http.request req # Net::HTTPResponse object
        #return render plain: res.header.inspect
        #return render plain: res.as_json
      end

      #return render plain: res['location']

      limit = 10
      case res
        when Net::HTTPSuccess     then res
        when Net::HTTPRedirection then request_server(res['location'], limit - 1)
        #else
        #res.error!
      end
    end

    def load_proxy_and_authorize
      @proxy = Proxy.find_by_id(params[:id])
      if @proxy.nil?
        return head :not_found
      end
      if current_service.id != @proxy.service.id && !(current_service.has_role?(:get, @proxy) || current_service.has_role?(:get, @proxy.service))
        return head :forbidden
      end
    end
  end
end
