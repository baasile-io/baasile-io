module Tester
  class ProcessRequestsController < DashboardController

    before_action :load_request

    # allow proxy functionality
    include RedisStoreConcern
    include ProxifyConcern

    def process_request

      @request_headers = {}
      request.headers.env.select{|k, _| k =~ /^HTTP_/}.each do |header|
        header_name =  header[0].sub(/^HTTP_/, '').gsub(/_/, '-')
        @request_headers[header_name] = header[1]
      end
      @request_method = request.method
      @request_content_type = request.content_type
      @request_body = request.raw_post
      @request_get = request.GET

      @proxy_response = proxy_request
      render status: @proxy_response.code, plain: @proxy_response.body
    rescue Api::ProxyError => e
      Rails.logger.error "Api::ProxyError: #{e.message}"
      if e.req
        metadata_request = {
          method: e.req.method,
          original_url: e.uri.to_s,
          headers: e.req.to_hash,
          body: e.req.body
        }
      end
      if e.res
        metadata_response = {
          status: e.res.code,
          body: e.res.body.to_s.force_encoding('UTF-8')
        }
      end
      metadata_full = {
        request: metadata_request,
        response: metadata_response
      }
      render json: {req: metadata_request, res: metadata_response, uri: e.uri.to_s, message: e.message, meta: e.meta}
    end

    def load_route
      if current_route.nil?
        raise BaseNotFoundError
      end
    end

    def current_route
      @current_route ||= current_request.route
    end

    def current_proxy
      @current_proxy ||= current_route.proxy
    end

    def use_test_settings?
      true
    end

    def authenticated_service
      current_service
    end

    def current_measure_token
      nil
    end

    def current_request
      @current_request
    end

    def load_request
      @current_request = Tester::Request.find(params[:id])
    end

  end
end
