module Api
  class RoutesController < ApiController
    before_action :authenticate_request!
    before_action :load_proxy_and_authorize
    before_action :load_route_and_authorize

    # allow proxy functionality
    include RedisStoreConcern
    include ProxifyConcern

    def show
      ret = proxy_authenticate @proxy.proxy_parameter if @proxy.proxy_parameter.authentication_mode != 'null'
      if ret == 'error'
        return render plain: @proxy_access_token
      end

      uri_str = "#{@route.protocol || @proxy.proxy_parameter.protocol}://#{@route.hostname}:#{@route.port}#{@route.url}?#{URI.encode_www_form(request.query_parameters)}"

      res = proxy_request uri_str

      case res
        when Net::HTTPSuccess     then render plain: res.body
        else
          render plain: res
      end
    end

    def load_proxy_and_authorize
      #render plain: "ok 1"
      @proxy = Proxy.find_by_id(params[:proxy_id])
      if @proxy.nil?
        return head :not_found
      end
      if current_service.id != @proxy.service.id && !(current_service.has_role?(:get, @proxy) || current_service.has_role?(:get, @proxy.service))
        return head :forbidden
      end
    end

    def load_route_and_authorize
      @route = @proxy.routes.find_by_id(params[:id])
      if @route.nil?
        return head :not_found
      end
      if current_service.id != @route.proxy.service.id && !(current_service.has_role?(:get, @route) || current_service.has_role?(:get, @route.proxy.service))
        return head :forbidden
      end
    end
  end
end
