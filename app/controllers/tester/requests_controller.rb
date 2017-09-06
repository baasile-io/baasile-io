module Tester
  class RequestsController < DashboardController

    before_action :load_routes, only: [:new, :create, :show, :edit, :update]
    before_action :load_request, only: [:show, :edit, :update]

    def index
      @collection = current_proxy.tester_requests.order(updated_at: :desc)
    end

    def edit

    end

    def show

    end

    def new
      @request = Tester::Requests::Standard.new(route_id: params[:route_id])
    end

    def create
      @request = Tester::Requests::Standard.new(requests_params)
      @request.user = current_user

      if @request.save

      else
        render :new
      end
    end

    def update
      @request.assign_attributes(requests_params)
      @request.user = current_user

      if @request.save

      else
        render :edit
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

      def load_request
        @request = current_proxy.tester_requests.find(params[:id])
      end

  end
end