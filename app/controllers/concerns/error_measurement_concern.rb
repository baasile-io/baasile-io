module ErrorMeasurementConcern
  extend ActiveSupport::Concern

  included do
  end

  private

  def do_request_error_measure(error_type, request, message = nil)
    ErrorMeasurement.transaction do
      create_error_measure(error_type, request, message)
    end
    true
  rescue
    false
  end


  def create_error_measure(error_type, request, message = nil)
    measure = ErrorMeasurement.create!(contract: current_contract, route: current_route, error_type: error_type, request: request, message: message)
  end
end