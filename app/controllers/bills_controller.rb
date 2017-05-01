class BillsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize
  before_action :load_bill, only: [:show, :print, :comments]

  # Authorization
  before_action :authorize_action

  def index
    @collection = if current_service
                    Bill.includes(:contract, :client, :startup).by_service(current_service)
                  else
                    Bill.includes(:contract, :client, :startup).by_user(current_user)
                  end
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

  def comments
    @new_comment = Comment.new(commentable: current_bill)
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

  def current_module
    'bill'
  end

  def current_bill
    @bill
  end

  def load_bill
    @bill = if current_service
              Bill.includes(:contract, :client, :startup).by_service(current_service).find(params[:id])
            else
              Bill.includes(:contract, :client, :startup).by_user(current_user).find(params[:id])
            end
  end

end
