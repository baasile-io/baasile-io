class BillsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize
  before_action :load_bill, only: [:show, :print]

  # Authorization
  before_action :authorize_action

  def index
    @collection = current_service.bills
  end

  def show
  end

  def print
    pdf_path = Bills::GeneratePdfBillService.new(current_bill).generate_pdf

    data = open(pdf_path)
    send_data data.read,
              disposition: 'attachment',
              filename: "abc.pdf",
              stream: 'true',
              buffer_size: '4096',
              type: 'application/pdf'
  end

  private

  def load_service_and_authorize
    if params.key?(:service_id)
      @service = Service.find(params[:service_id])
      unless @service.is_activated?
        flash[:error] = I18n.t('misc.service_not_activated')
        redirect_to service_path(current_service)
      end
    else
      @service = nil
    end
  end

  def current_authorized_resource
    current_service
  end

  def current_service
    return nil unless params[:service_id]
    @service
  end

  def current_bill
    @bill
  end

  def load_bill
    @bill = current_service.bills.find(params[:id])
  end

end
