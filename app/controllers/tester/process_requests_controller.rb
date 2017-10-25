module Tester
  class ProcessRequestsController < DashboardController

    before_action :load_request

    # allow proxy functionality
    include RedisStoreConcern
    include ProxifyConcern

    def process_request

      @cache_token_prefix = "#{controller_name}#{DateTime.now.to_s}"
      @use_test_settings = !(params[:use_test_settings] == 'false')

      @request_method = current_request.method
      @request_content_type = current_request.format

      @request_headers = request_build_headers
      @request_body = request_build_body
      @request_get = request_build_get

      proxy_initialize
      @proxy_response = proxy_request

      response_headers = {}
      @proxy_response.header.each_header do |key, value|
        response_headers[key] = value
      end

      @result = {
        status: @proxy_response.code,
        error: false,
        response: {
          status: @proxy_response.code,
          headers: response_headers,
          body: @proxy_response.body.to_s.force_encoding('UTF-8')
        }
      }

      render 'tester/requests/show'

    rescue Api::ProxyError => e
      Rails.logger.error "Tester::ProcessRequests::ProxyError: #{e.message}"

      status = I18n.t("errors.api.#{e.code}.status", locale: :en)

      @result = {}.tap do |result|

        result[:status] = status
        result[:error] = true
        result[:error_title] = I18n.t("errors.api.#{e.code}.title", locale: :en)
        result[:error_message] = I18n.t("errors.api.#{e.code}.message", locale: :en)

        if e.res
          result[:response] = {
            status: e.res.code,
            headers: e.res.to_hash.transform_values {|v| v.join(', ')},
            body: e.res.body.to_s.force_encoding('UTF-8')
          }
        end

        if e.req
          result[:request] = {
            method: e.req.method,
            original_url: e.uri.to_s,
            headers: e.req.to_hash.transform_values {|v| v.join(', ')},
            body: e.req.body
          }
        end

      end

      render 'tester/requests/show'
    end

    def request_build_body
      case current_request.format

        when 'application/json'
          current_request.request_body

        when 'application/x-www-form-urlencoded'
          Rack::Utils.build_nested_query(JSON.parse(current_request.request_body))

      end
    rescue
      current_request.request_body
    end

    def request_build_headers
      {}.tap do |parameters|
        current_request.tester_parameters_headers.each do |header_parameter|
          parameters[header_parameter.name.upcase.gsub(/_/, '-')] = header_parameter.value
        end
      end
    end

    def request_build_get
      {}.tap do |parameters|
        current_request.tester_parameters_queries.each do |query_parameter|
          request_parse_get_param(
            query_parameter,
            Rack::Utils.parse_nested_query(query_parameter.name),
            parameters
          )
        end
      end
    end

    def request_parse_get_param(query_parameter, query_parameter_hash, parameters)
      key, value = query_parameter_hash.first

      if value.is_a?(Hash)
        parameters[key] ||= {}
        request_parse_get_param(query_parameter, value, parameters[key])
      else
        parameters[key] ||= query_parameter.value
      end
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
