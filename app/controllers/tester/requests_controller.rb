module Tester
  class RequestsController < DashboardController

    def new
      @request = Tester::Request.new(route_id: params[:route_id])
    end

  end
end