require 'openssl'

module Api
  class ProxiesController < FunctionalitiesController
    before_action :load_proxy_and_authorize

    def show

      return render plain: request.fullpath.inspect
      if @proxy.proxy_parameter.authentication_mode != 'null'
        #authenticate Baasile IO to proxy URL
      end

      proxy_parameter = @proxy.proxy_parameter
      uri_str = "#{proxy_parameter.protocol}://#{proxy_parameter.hostname}:#{proxy_parameter.port}/#{params[:url]}"

      #Rails.logger.error uri
      #response = HTTParty.get(uri, {format: :html, verify: false})

      #render plain: response.body

      uri = URI.parse uri_str
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        http.ssl_version = :SSLv2

        res = http.request request # Net::HTTPResponse object
        render plain: res.body
      end
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

    def load_proxy_and_authorize
      @proxy = Functionality.find_by_id(params[:id])
      if @proxy.nil?
        return head :not_found
      end
      if current_service.id != @proxy.service.id && !(current_service.has_role?(:get, @proxy) || current_service.has_role?(:get, @proxy.service))
        return head :forbidden
      end
      if @proxy.type != 'proxy'
        return head :not_found
      end
    end
  end
end
