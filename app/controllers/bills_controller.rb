class BillsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service_and_authorize
  before_action :load_bill, only: [:show, :print, :comments, :mark_as_paid, :mark_platform_contribution_as_paid]

  # Authorization
  before_action :authorize_action

  # allow get measure info to show
  include ShowMeasurementConcern

  def index
    @collection = if current_service
                    Bill.includes(:contract, :client, :startup).by_service(current_service)
                  else
                    Bill.includes(:contract, :client, :startup).by_user(current_user)
                  end
  end

  def show
    @logotype_service = LogotypeService.new
  end

  def print
    pdf_path = Bills::GeneratePdfBillService.new(current_bill).generate_pdf

    data = open(pdf_path)
    send_data data.read,
              disposition: 'attachment',
              filename: "#{I18n.t('bills.show.title',
                                  start_date: I18n.l(current_bill.start_date, format: :default),
                                  end_date: I18n.l(current_bill.end_date, format: :default))}.pdf",
              stream: 'true',
              buffer_size: '4096',
              type: 'application/pdf'
  end

  def comments
    @new_comment = Comment.new(commentable: current_bill)
  end

  def mark_as_paid
    if current_user.is_user_of?(current_bill.contract.startup)
      current_bill.startup_paid = true
      if current_bill.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bill'))
      else
        flash[:error] = current_bill.errors.full_messages.join(', ')
      end
    else
      flash[:error] = I18n.t('misc.not_authorized')
    end
    redirect_to polymorphic_path([current_service, current_bill])
  end

  def mark_platform_contribution_as_paid
    if current_user.is_superadmin?
      current_bill.platform_contribution_paid = true
      if current_bill.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bill'))
      else
        flash[:error] = current_bill.errors.full_messages.join(', ')
      end
    else
      flash[:error] = I18n.t('misc.not_authorized')
    end
    redirect_to polymorphic_path([current_service, current_bill])
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
    if current_service.nil?
      'bill'
    else
      'dashboard'
    end
  end

  def current_bill
    @bill
  end

  def load_bill
    @bill = if current_service
              Bill.includes(:contract).by_service(current_service).find(params[:id])
            else
              Bill.includes(:contract).by_user(current_user).find(params[:id])
            end
  end

end
