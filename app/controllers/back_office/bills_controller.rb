module BackOffice
  class BillsController < BackOfficeController

    before_action :load_bill, only: [:show, :edit, :update, :comments, :audit]

    def index
      @collection = Bill.includes(:client, :startup).order(created_at: :desc)
    end

    def edit
      @logotype_service = LogotypeService.new
    end

    def show
      redirect_to_edit
    end

    def comments
      @new_comment = Comment.new(commentable: @bill)
      @comments = @bill.comments.order(created_at: :desc)
    end

    def update
      if params[:mark_startup_as_paid].present?
        @bill.mark_startup_as_paid
      else
        @bill.startup_paid = nil
      end

      if params[:mark_platform_contribution_as_paid].present?
        @bill.mark_platform_contribution_as_paid
      else
        @bill.platform_contribution_paid = nil
      end

      if @bill.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bill'))
        redirect_to back_office_bills_path
      else
        render :edit
      end
    end

    private

    def redirect_to_show
      redirect_to back_office_bill_path(@bill)
    end

    def redirect_to_edit
      redirect_to edit_back_office_bill_path(@bill)
    end

    def load_bill
      @bill = Bill.find(params[:id])
    end

  end
end
