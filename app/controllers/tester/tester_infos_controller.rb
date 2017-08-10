module Tester
  class TesterInfosController < ApplicationController
    before_action :authenticate_user!
    #before_action :authorize_superadmin!
    before_action :load_clients, only: [:select_client, :select_proxy, :lanch_test, :select_route, :req_result]

    layout 'tester'

    def index

    end

    def new
      @tester_info = TesterInfo.new
      @tester_info.req_url = ENV['BAASILE_IO_HOSTNAME'] + ':' + ENV['PORT'] + '/api/v1/' + @proxy.service.subdomain + '/proxies/' + @proxy.subdomain + '/routes/' + @route.subdomain + '/request/'
      @tester_info.auth_url = ENV['BAASILE_IO_HOSTNAME'] + ':' + ENV['PORT'] + '/api/oauth/token'
    end

    def create

    end

    def select_client

    end

    def select_route
      check_proxy
    end

    def select_proxy
      if check_client
        load_proxies
      end
    end

    def req_result
      if check_route
        if load_tester_info
          uri = URI.parse @tester_info.auth_url
          req = Net::HTTP::Post.new @tester_info.auth_url
          req.content_type = 'application/x-www-form-urlencoded'
          params = {
              client_id: @tester_info.service.client_id,
              client_secret: @tester_info.service.client_secret
          }
          params[:scope] = @tester_info.proxy.service.subdomain
          req.set_form_data(params)

          http = Net::HTTP.new ENV['BAASILE_IO_HOSTNAME'], ENV['PORT']
          http.use_ssl = uri.scheme == 'https'
          res = http.request req
          @res = JSON.pretty_generate(JSON.parse(res.read_body))
          #@res =simple_format @res
          request_obj = case @tester_info.req_type.to_sym
                          when :get then Net::HTTP::Get
                          when :post then Net::HTTP::Post
                          when :head then Net::HTTP::Head
                          when :put then Net::HTTP::Put
                          when :delete then Net::HTTP::Delete
                        end
          res_hash = JSON.parse(res.read_body)

          uri = URI.parse @tester_info.req_url
          req = request_obj.new @tester_info.req_url
          req.content_type = 'application/x-www-form-urlencoded'
          req['Authorization'] = res_hash["access_token"]
          #req['measureTokenId'] = '123456789'
          #req['OpenRH-ClientTokenID'] = '123456789'

          http = Net::HTTP.new ENV['BAASILE_IO_HOSTNAME'], ENV['PORT']
          http.use_ssl = uri.scheme == 'https'
          res1 = http.request req
          begin
            @res1 = JSON.pretty_generate(JSON.parse(res1.read_body))
          rescue
            doc = Nokogiri::HTML(res1.read_body)
            @res1 = doc.at('body').inner_html.html_safe
          end
        end
      end
    end

    def lanch_test
      if check_route
        @tester_info = TesterInfo.new
        @tester_info.req_url = '/api/v1/' + @proxy.service.subdomain + '/proxies/' + @proxy.subdomain + '/routes/' + @route.subdomain + '/request/'
        @tester_info.auth_url = '/api/oauth/token'
      end
    end

    private

    def load_tester_info
      @tester_info = TesterInfo.new
      @tester_info.user = current_user
      @tester_info.service = @client
      @tester_info.proxy = @proxy
      @tester_info.assign_attributes(tester_info_params)
      true
    end

    def load_proxies
      @proxies = current_client.contracts_as_client.map do |contract|
        if contract.status.to_sym == :validation || contract.status.to_sym == :validation_production
          contract.proxy
        end
      end.reject(&:blank?).uniq
      @client.proxies.each do |proxy|
        @proxies << proxy
      end
    end

    def check_client
      if current_client.nil?
        redirect_to select_client_tester_tester_infos_path
        false
      end
      true
    end

    def check_proxy
      return false unless check_client
      if current_proxy.nil?
        redirect_to select_proxy_tester_tester_info_path(@client)
        false
      end
      true
    end

    def check_route
      return false unless check_proxy
      if current_route.nil?
        redirect_to select_route_tester_tester_info_path(@client, proxy_id: @proxy.id)
        false
      end
      true
    end

    def authorize_superadmin!
      return head(:forbidden) unless current_user.is_superadmin?
    end

    def current_client
      @client = @clients.find_by(id: params[:id]) if params[:id].present?
    end

    def current_proxy
      @proxy = Proxy.find_by(id: params[:proxy_id]) if params[:proxy_id].present?
    end

    def current_route
      @route = Route.find_by(id: params[:route_id]) if params[:route_id].present?
    end

    def tester_info_params
      params.require(:tester_info).permit(:auth_url, :req_url, :req_type)
    end

    def load_clients
      @clients = (current_service.nil? ? current_user.services.clients_or_startups : current_service.children.clients_or_startups)
    end

    def current_module
      'tester'
    end
  end
end
