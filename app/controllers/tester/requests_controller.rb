module Tester
  class RequestsController < DashboardController

    before_action :load_routes, only: [:new, :create]

    def new
      @request = Tester::Requests::Standard.new(route_id: params[:route_id])
    end

    def create
      @request = Tester::Requests::Standard.new(requests_params)

      if @request.save

      else
        render :new
      end
    end

    def current_proxy
      @current_proxy ||= Proxy.find(params[:proxy_id])
    end

    def current_service
      @current_service ||= current_proxy.service
    end

    private

      def requests_params
        params.require(:tester_request).permit(:route_id, :method, :format, :body)
      end

      def load_routes
        @routes = current_proxy.routes
      end

  end
end