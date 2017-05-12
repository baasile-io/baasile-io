module BackOffice
  class ErrorMeasurementsController < BackOfficeController
    def index
      @collection = ErrorMeasurement.all.includes(:client, :proxy).order(created_at: :desc)
    end

    def show
      @error_measurement = ErrorMeasurement.find_by_id(params[:id])
      render 'error_measurements/show'
    end
  end
end