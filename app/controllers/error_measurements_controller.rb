class ErrorMeasurementsController < DashboardController
  before_action :load_error_measurement, only: [:show]

  def index
    @collection = if !current_route.nil?
                    current_proxy.error_measurements
                  elsif !current_contract.nil?
                    current_contract.error_measurements
                  elsif !current_service.nil?
                    current_service.error_measurements
                  end.order(created_at: :desc)
  end

  def show
  end

  private

  def load_error_measurement
    @error_measurement = ErrorMeasurement.find_by_id(params[:id])
  end

  def current_proxy
    @current_proxy ||= current_service.proxies.find_by_id(params[:proxy_id]) rescue nil
  end

  def current_route
    @current_route ||= current_proxy.find_by_id(params[:route_id]) rescue nil
  end

  def current_contract
    @current_contract ||= Contract.find_by_id(params[:contract_id])
  end
end