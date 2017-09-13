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
      current_route.query_parameters.not_forbidden.each do |qp|
        case qp.query_parameter_type.to_sym
          when :get
            @request.tester_parameters_queries.build(name: qp.name, value: qp.default_value)
          when :header
            @request.tester_parameters_headers.build(name: qp.name, value: qp.default_value)
        end
      end
    end

    def create
      @request = Tester::Requests::Standard.new(requests_params)
      @request.user = current_user

      if @request.save
        respond_to do |format|
          format.html { redirect_to_show }
          format.js { render :new }
        end
      else
        render :new
      end
    end

    def update
      @request.assign_attributes(requests_params)
      @request.user = current_user

      if @request.save
        respond_to do |format|
          format.html { redirect_to_show }
          format.js { render :show }
        end
      else
        render :edit
      end
    end

    def redirect_to_show
      redirect_to service_proxy_tester_request_path(current_service, current_proxy, @request)
    end

    def current_proxy
      @current_proxy ||= current_service.proxies.find(params[:proxy_id])
    end

    def current_route
      @current_route ||= current_proxy.routes.find_by_id(params[:route_id])
    end

    def current_service
      @current_service ||= Service.find(params[:service_id])
    end

    private

      def requests_params
        params
          .require(:tester_request)
          .permit(
            :route_id,
            :method,
            :format,
            :use_authorization,
            :body,
            {tester_parameters_headers_attributes: [:id, :type, :name, :value, :_destroy]},
            {tester_parameters_queries_attributes: [:id, :type, :name, :value, :_destroy]}
          )
      end

      def load_routes
        @routes = current_proxy.routes
      end

      def load_request
        @request = current_proxy.tester_requests.includes(:tester_parameters_headers).find(params[:id])
      end

  end
end